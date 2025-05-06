#include "CCDIKTest.h"
#include <Object/C3DObject.h>
#include <Scene/CSceneController.h>
#include <Message/Console.h>

namespace component
{
	CCDIKTest::CCDIKTest(const std::string& ComponentName, const std::string& RegistryName):
		CComponent(ComponentName, RegistryName),
		m_TargetNode(nullptr)
	{
	}

	CCDIKTest::~CCDIKTest()
	{
	}

	bool CCDIKTest::OnLoaded(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<scene::CSceneController>& SceneController,
		const std::shared_ptr<object::C3DObject>& Object, const std::shared_ptr<object::CNode>& SelfNode)
	{
		if (!Object) return false;

		m_TargetNode = Object->FindNodeByName("Target");
		if (!m_TargetNode) return false;

		// Link0 ~ 4の順番(根本から先端)に入っていて0が根本・4が先端
		// Link数は先端も入れて全部で5
		for (int i = 0; i < 5; i++)
		{
			auto LinkNode = Object->FindNodeByName("Link.00" + std::to_string(i));
			if (!LinkNode) return false;

			m_LinkList.push_back(LinkNode);
		}

		return true;
	}

	bool CCDIKTest::Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<camera::CCamera>& Camera, const std::shared_ptr<projection::CProjection>& Projection,
		const std::shared_ptr<graphics::CDrawInfo>& DrawInfo, const std::shared_ptr<input::CInputState>& InputState)
	{
		if (!m_TargetNode || m_LinkList.empty()) return true;
		
		// ターゲットのアニメーション
		{
			float r = 2.0f, t = DrawInfo->GetSecondsTime(), f = DrawInfo->GetSecondsTime();

			glm::vec3 Pos = m_TargetNode->GetPos();
			Pos.x = r * glm::sin(t) * glm::cos(f);
			Pos.y = r * glm::sin(t) * glm::sin(f);
			Pos.z = r * glm::cos(t);

			m_TargetNode->SetPos(Pos);
		}

		// 注意点 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// せん断が発生してしまうのでCCDIKのリンクのスケールは必ず(1, 1, 1)になるようにする
		// つまり複数メッシュが親子ノード関係になっており、それぞれのスケールのノルム(ベクトルの長さ)が1出ない場合、せん断が発生する
		// せん断とは例えば自ノードを90度回転させてもなぜか回転していなかったり、45度にすると形が斜めになって崩れるような見た目になる状態のことである
		// たぶん自ノードの親ノードのスケールノルムが1ではない時に、自ノードを回転すると発生するのかもしれない
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		const glm::vec3 TargetPos = m_TargetNode->GetWorldPos();

		// 元のノード情報をコピーしておく
		// CCDIKはコピーノードに対して行い最後に反映するため
		std::vector<std::shared_ptr<object::CNode>> LocalLinkList;
		{
			std::shared_ptr<object::CNode> LocalParentNode = m_LinkList[0]->GetParentNode();

			for (auto& SrcNode : m_LinkList)
			{
				std::shared_ptr<object::CNode> LocalNode = std::make_shared<object::CNode>(-1, -1);

				LocalNode->SetParentNode(LocalParentNode);
				LocalNode->SetPos(SrcNode->GetPos());
				LocalNode->SetRot(SrcNode->GetRot());
				LocalNode->SetScale(SrcNode->GetScale());
				LocalNode->SetWorldMatrix(SrcNode->GetWorldMatrix());

				LocalLinkList.push_back(LocalNode);

				LocalParentNode = LocalNode;
			}
		}

		//
		int NumOfLink = static_cast<int>(LocalLinkList.size());

		int NumOfCicle = 64;
		int Count = 0;
		bool DoLoop = true;

		std::shared_ptr<object::CNode> EndNode = LocalLinkList[NumOfLink - 1];

		while(DoLoop && Count < NumOfCicle)
		{
			glm::vec3 EndPos = EndNode->GetWorldPos();

			for (int i = NumOfLink - 2; i >= 0; i--)
			{
				std::shared_ptr<object::CNode> LinkNode = LocalLinkList[i];

				glm::vec3 LinkPos = LinkNode->GetWorldPos();

				glm::vec3 e_i = glm::normalize(EndPos - LinkPos);
				glm::vec3 t_i = glm::normalize(TargetPos - LinkPos);

				// 内積
				// なぜか1を微妙に越してNaNになってしまうことがあるのでちゃんとクランプしておく
				float dot = glm::clamp(glm::dot(e_i, t_i), -1.0f, 1.0f);

				// 外積
				glm::vec3 axis = glm::cross(e_i, t_i);

				glm::quat rot;
				
				if (glm::length(axis) < 1e-6f)
				{
					if (glm::sign(dot) == 1.0f)
					{
						// 同じ方向に平行な時は回転の必要がない
						continue;
					}
					else
					{
						// 反対方向に平行なので任意の垂直軸で180度回転する
						glm::vec3 XAxis = glm::vec3(1.0f, 0.0f, 0.0f);
						glm::vec3 YAxis = glm::vec3(0.0f, 1.0f, 0.0f);
						
						glm::vec3 SubAxis = glm::cross(XAxis, e_i);

						if (glm::length(SubAxis) < 1e-6f)
						{
							// X軸とも平行なのでY軸の方を使う(さすがにXとYを見れば大丈夫なはず？)
							SubAxis = glm::cross(YAxis, e_i);
						}

						rot = glm::angleAxis(3.1415f, glm::normalize(SubAxis)); // 回転角度がおかしくなってしまうので回転取得前にちゃんと軸を正規化しておく
					}
				}
				else
				{
					// 通常通り内積結果から回転
					float angle = glm::acos(dot);
					rot = glm::angleAxis(angle, glm::normalize(axis)); // 回転角度がおかしくなってしまうので回転取得前にちゃんと軸を正規化しておく
				}

				if (std::isnan(rot.x) || std::isnan(rot.y) || std::isnan(rot.z) || std::isnan(rot.w))
				{
					Console::Log("[Error] CCDIK - found NaN value in ik rot.\n");
					return false;
				}

				LinkNode->SetRot(rot * LinkNode->GetRot());

				// 回転角度制限
				{
					// まずクォータニオンを回転軸と角度にばらす
					// クォータニオンの定義は以下
					// (λx, λy, λz): 回転軸, theta: 回転角度
					// quat.x = λx * sin(theta / 2.0)
					// quat.y = λy * sin(theta / 2.0)
					// quat.z = λz * sin(theta / 2.0)
					// quat.w = cos(theta / 2.0)
					glm::quat q = LinkNode->GetRot();

					float LinkTheta = 2.0f * glm::acos(q.w);

					// wが1の時は任意軸回転である
					glm::vec3 LinkAxis = glm::vec3(0.0f, 1.0f, 0.0f);
					
					if (q.w != 1.0f)
					{
						LinkAxis = glm::vec3(q.x, q.y, q.z) / glm::sin(LinkTheta / 2.0f);
					}

					// 回転角度をクランプする
					LinkTheta = glm::clamp(LinkTheta, -3.1415f * 0.5f, 3.1415f * 0.5f);

					// クォータニオンに直す
					q = glm::angleAxis(LinkTheta, LinkAxis);

					// だんだん歪が溜まってきてNaNになってしまうのできちんと最後には正規化しておく
					q = glm::normalize(q);

					// 再設定
					LinkNode->SetRot(q);
				}

				if (std::isnan(rot.x) || std::isnan(rot.y) || std::isnan(rot.z) || std::isnan(rot.w))
				{
					Console::Log("[Error] CCDIK - found NaN value in ik rot. when clamp rotation.\n");
					return false;
				}

				// Linkノードのワールド行列を再計算する
				for (int n = i; n < NumOfLink; n++)
				{
					std::shared_ptr<object::CNode> ReCalcNode = LocalLinkList[n];

					const auto& ParentNode = ReCalcNode->GetParentNode();
					if (!ParentNode)
					{
						// 親ノードがない時はローカル行列をワールド行列として渡す
						ReCalcNode->SetWorldMatrix(ReCalcNode->GetLocalMatrix());

						continue;
					}

					glm::mat4 NewWorldMatrix = ParentNode->GetWorldMatrix() * ReCalcNode->GetLocalMatrix();
					ReCalcNode->SetWorldMatrix(NewWorldMatrix);
				}

				// EndNodeの座標を更新
				EndPos = EndNode->GetWorldPos();

				if (glm::distance2(TargetPos, EndPos) < 0.01f)
				{
					// 終了
					DoLoop = false;
					break;
				}
			}
			
			Count++;
		}

		// CCDIKの演算結果を元のノードに反映する
		for (int i = 0; i < static_cast<int>(m_LinkList.size()); i++)
		{
			auto& LocalNode = LocalLinkList[i];
			auto& SrcNode = m_LinkList[i];

			// ワールド行列だけを反映する
			// ローカル座標に反映しないことで次のフレームのCCDIK演算時にT-Pose(元の姿勢)にリセットして演算を行うことができ、演算結果が安定するようになる
			// このようにしないと途中で変な方向を向いたりぶるぶるしたりして不安定になる
			SrcNode->SetWorldMatrix(LocalNode->GetWorldMatrix());

			/*// 回転にローパスフィルタをかけて急激に変化しないようにする
			float t = DrawInfo->GetDeltaSecondsTime() * 8.0f;
			glm::quat filterRot = glm::slerp(SrcNode->GetRot(), LocalNode->GetRot(), t);

			SrcNode->SetRot(filterRot);

			//
			const auto& ParentNode = SrcNode->GetParentNode();
			if (!ParentNode)
			{
				// 親ノードがない時はローカル行列をワールド行列として渡す
				SrcNode->SetWorldMatrix(SrcNode->GetLocalMatrix());

				continue;
			}

			glm::mat4 NewWorldMatrix = ParentNode->GetWorldMatrix() * SrcNode->GetLocalMatrix();
			SrcNode->SetWorldMatrix(NewWorldMatrix);*/
		}

		// アルゴリズム的には合っているが、見栄えのためにTargetがEndの先端に表示されるようにする
		// EndNodeの位置に表示されればいいので根元に描画されるのは合っているのだが、モデリング的にどう対処したらいいのかわからない
		// WorldMatrixは次のフレームで即リセットされるのでCCDIKの計算には影響ないはず
		{
			glm::quat EndWorldRot;
			math::CTransform::CastModelMatrixToRotation(EndNode->GetWorldMatrix(), EndWorldRot);

			m_TargetNode->SetWorldPos(m_TargetNode->GetPos() + EndWorldRot * glm::vec3(0.0f, 1.0f, 0.0f));
		}

		return true;
	}
}