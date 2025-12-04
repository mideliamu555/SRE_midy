
## 作成予定

| テーマ                           | 内容                                     | ポイント                        |
| ----------------------------- | -------------------------------------- | ----------------------------- |
| **1. CI/CD自動デプロイ環境**          | GitHub Actions → ECS or Lambda に自動デプロイ | 🔹Pipeline設計力 🔹テスト自動化 🔹権限設計 |
| **2. IaCによる環境構築**             | TerraformでVPC〜ALB〜ECS〜CloudWatchまで構築   | 🔹再現性 🔹構成の理解力 🔹タグ/変数設計センス   |
| **3. 可観測性（Observability）**    | Prometheus + Grafanaでメトリクス可視化          | 🔹メトリクス選定 🔹アラート閾値設計 🔹SLO定義  |
| **4. ログ集約とトレーシング**            | CloudWatch Logs + X-Ray or Loki構成      | 🔹障害解析力 🔹トレーシング理解            |
| **5. 障害時の自動復旧（Self-healing）** | CloudWatch Alarm + Lambdaで自動復旧         | 🔹運用自動化 🔹リライアビリティ思考          |


# AWS SRE Infrastructure Example

## 目的
AWS上で再現可能なSRE基盤をTerraformとGitHub Actionsで自動構築。

## 構成概要
- IaC: Terraform
- CI/CD: GitHub Actions
- Container: ECS(Fargate)
- Observability: CloudWatch + Grafana

## 主なポイント
- 環境ごとの自動デプロイ
- エラーバジェット設計の考え方を導入
- 監視ダッシュボードとアラート通知自動化

## デモ
https://youtu.be/xxxxxx （※動画あると最高）

## 学び・改善点
- Terraformのモジュール化で再利用性UP
- ECSのBlue/Greenデプロイでダウンタイム最小化
