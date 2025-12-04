■概要
基本構成(ALB、ECS、RDS)のtfファイルです。
デプロイ方法は、ブルーグリーンデプロイメントを採用しています。
CloudTechの講座を受講しておくとより効果的に学べるかと思います。

NAT Gatewayの有無を variables.tfで制御可能です。
default = false　から　true に変更することで、
NAT Gateway を public-subnet-a に作成します。
また、ECSタスクが立ち上がるサブネットも変更されるようにしています。
false → Public Subnet
true → Protected Subnet


■デプロイ手順
次の手順でデプロイを行なってください。

①03_tf_sample_module/dev で terraform init を実行
②module "compute"、module "database"を全てコメントアウト
③terraform applyを実行し、network関連リソースをデプロイ
④module "compute"のコメントアウトを外し、terraform applyを実行
⑤module "database"のコメントアウトを外し、terraform applyを実行


■ディレクトリ構造
ディレクトリ構造は以下の通りです。

├── README.md
├── dev
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
└── modules
    ├── 01_network
    │   ├── 01_variables.tf
    │   ├── 02_outputs.tf
    │   ├── 03_vpc.tf
    │   ├── 04_subnet.tf
    │   ├── 05_route_table.tf
    │   ├── 06_security_group.tf
    │   └── 07_alb.tf
    ├── 02_compute
    │   ├── 01_variables.tf
    │   ├── 02_outputs.tf
    │   ├── 03_ecs.tf
    │   └── 04_codedeploy.tf
    └── 03_database
        ├── 01_variables.tf
        ├── 02_outputs.tf
        └── 03_rds.tf


■ディレクトリ構造等について補足
ECSとCodeDeployに必要なIAMロール及びIAMポリシーは、
03_ecs.tf、04_codedeploy.tf内に記載しました。
security等のModuleを作り、別途管理する方法もありますが、
規模が小さい場合は、関連リソース内に記載する方法がわかりやすいと判断しています。

また、セキュリティグループも同様に関連リソース内に記載する方法がよく見受けられますが、
こちらの構成では、06_security_group.tfにまとめて記載しています。
Monolithとの違いを明確にするため、極力構成を変更しないよう配慮しているためです。

また、同様の理由から、システム名や環境名等は変数化していません。
実際にmoduleを使っていく場合は、以下のように変数化していくと汎用性が上がります。
sample-dev-vpc　→　${sysname}-${env}-vpc


■module間でリソースを参照したい場合
以下のように3つのtfファイルで指定が必要になります。

例：01_network の subnet を 02_compute のmoduleで参照したい場合
①01_network/02_outputs.tfで、output "subnet"を指定
②dev/main.tfのmodule "compute"で、subnet = module.network.subnetを指定
③02_compute/01_variables.tfでvariable "subnet"を指定

※map関数を使用していますが、必須ではありません。
1つずつoutputとvariableを定義していく方法もよく見られます。
記載方法は意見が分かれます。
今回はコードの見やすさを重視し、map関数を使用しました。


ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
以下、monolithと同様の内容です。

■補足①NAT Gatewayの有無を切り替える場合
ECSサービスとCodeDeployを削除してから、切り替える必要があります。
下記コマンドでリソースを削除の上、defaultの値を変更し、再度Applyを実行してください。
terraform destroy -target=aws_codedeploy_deployment_group.this
terraform destroy -target=aws_ecs_service.fargate

■補足②本構成の料金
基本的に最低スペックで構成していますが、課金は高めです。
再構築はすぐできるので、使用していない場合は削除推奨です。terraform destroyコマンドで削除可能です。

以下金額が課金されます。(概算です。無料利用枠がある場合はさらに安くになります。)
・Aurora MySQL：0.263USD/Hour
・NAT Gateway：0.062USD/Hour
・ECSタスク：0.015405USD/Hour
・ALB：＝0.0243USD/Hour
・Public IP：0.005*2USD/Hour(ALBのIP)
Aurora MySQLを除いた1日課金参考額→2.7USD (約430円)
Aurora MySQLを除いた1ヶ月課金参考額→81USD (約13000円)
※通信料やストレージ料金など軽微な料金は除く
※ECSタスクは1つにつき発生する金額
※Public Subnetに構築した場合はPublic IP料金がタスクごとに発生する
※Aurora MySQLのインスタンスクラスについて、db.t3.smallは現在サポート外になりました。テスト用のリソースなのでご容赦ください。
 延長サポート料金が高いためリソースの停止と削除を忘れずに行なってください。
 1週間後に自動起動するので、停止ではなく当日削除推奨です。
 

■補足③依存関係について
基本的にはTerraformtが依存関係について考慮して、順番に構築を行なってくれます。ただし、特にモノリス構造の場合は一度にApplyするリソースが多くなるため、上手くいかないリソースも出てきます。もしエラーが起きたら再度Applyしてみてください。
こちらでも depends_on のパラメータを追加して構築順を制御はしています。


■補足④lifecycle ignore_changesについて
上記ブロックで指定したリソースは、一度構築した後は変更を無視する設定となります。
コンソール上で変更してもTerraformの管理外となります。
特にブルーグリーンデプロイを行うとターゲットグループが変更されるため、変更を無視する必要があります。
ECSタスク数もTerraformの管理外にした方が都合が良い場合が多いので指定しています。タスク数を変更する場合はコンソールから行なってください。