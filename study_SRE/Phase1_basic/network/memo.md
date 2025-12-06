新しいフォルダ/ファイル名	目的と学習内容	SREへの繋がり

overview
    ネットワークの全体像を再確認します。学習の目的、ゴール、各技術分野（レイヤー）の関連性を記述します。	学習のKPIやゴールを明確にし、モチベーションを維持します。

basic_theory	
    基礎理論を体系的に学習します。	



OSI_TCP-IP	
    OSI参照モデルとTCP/IPモデルの基礎。各レイヤーの役割。	トラブルシューティング（Traceroute、Pingなど）でどのレイヤーの問題かを切り分ける基礎となります。


Protocols	
    ARP, DHCP, DNS, HTTP/S の仕組み。負荷分散アルゴリズムの基礎。	サービスに不可欠なDNSやHTTP/Sの監視・チューニングに直結します。

AWS_practical	
    AWSネットワークの主要サービスとベストプラクティスを学びます。	

VPC_Subnet	
    VPC、サブネット、ルーティングテーブル、インターネットゲートウェイ (IGW) の設定。	IaC (Terraform) でのネットワーク構成管理の核となります。

Security_Group_ACL	
    セキュリティグループとネットワークACL (NACL) の設計と違い。	セキュリティエンジニアリングの基礎として、最小権限の原則をネットワークレベルで適用します。

LoadBalancer_Route53	
    ELB (ALB/NLB) の設定、Route 53のルーティングポリシー、ヘルスチェック。	高可用性・スケーラビリティを担保するSREの主要業務です。

Connect_Hybrid	
    VPN、Direct Connect (DX)、Transit Gateway (TGW) など、オンプレミスや他VPCとの接続。	大規模なインフラにおけるネットワーク集約やコスト最適化に関わります。

ready_cicd	
    TerraformやCloudFormationなどのIaCでネットワークリソースをデプロイするコードサンプルや手順。	ネットワーク構成の変更管理と自動化を実践します。

ready_iac
    上記のIaCコードをGitHub ActionsなどでCI/CDパイプラインに組み込む手順。	GitOpsによるインフラ管理を実践します。