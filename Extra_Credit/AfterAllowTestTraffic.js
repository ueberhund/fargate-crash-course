'use strict';

 const AWS = require('aws-sdk');
 const axios = require('axios');
 const codedeploy = new AWS.CodeDeploy();
 
 const TARGET_URL = "YOUR_TARGET_TEST_URL";

 exports.handler = async function (event, context, callback) {

  //Log the event
 	console.log(JSON.stringify(event));

  //Ensure test traffic is fully shifted over to new target group
  console.log("Waiting 30 seconds");
  await new Promise(resolve => setTimeout(resolve, 30 * 1000));

 	// Complete the AfterAllowTestTraffic hook by sending CodeDeploy the validation status
 	var params = {
 		deploymentId: event.DeploymentId,
 		lifecycleEventHookExecutionId: event.LifecycleEventHookExecutionId,
 		status: "Failed" // status can be 'Succeeded' or 'Failed'
 	};
 	
 	//Perform validation on the target url
 	try {
 	 const response = await axios(TARGET_URL);
 	 console.log(response);
 	 if (response.status == 200 && response.data.indexOf("YOUR_SEARCH_CRITERIA_TO_ENSURE_SUCCESSFUL_ROLLOUT") >= 0) {
 	  params.status = "Succeeded";
 	 } 
 	} catch (err) {
 	  console.error(err);
 	}

 	// Pass AWS CodeDeploy the prepared validation test results.
 	try {
 	 await codedeploy.putLifecycleEventHookExecutionStatus(params).promise();
 	 console.log("Successfully reported hook results");
 	 callback(null, "Successfully reported hook results");
 	} catch (err) {
 	 console.log(err);
 	 console.error("Failed to report hook results");
 	 callback("Falied to report hook results");
 	}
 }
 
