## Extra Credit

If you want to enable Blue/Green deploys while testing your site before live traffic is sent to it, you'll need to use CodeDeploy directly.

Follow the steps in [2_Setup_a_new_app_with_blue_green_deploy](../2_Setup_a_new_app_with_blue_green_deploy)
When setting up your production listener port (step #10), also add a test listener. I added port 8080 as my test listener. You'll also need to update your inbound security group to allow access through port 8080.

Next create an [AppSpec.yml](ecsAppSpec.yml) file
