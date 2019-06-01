var mysql = require('mysql');
var apn = require('apn');

var deviceToken = []

var con = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "theFAME44",
  database: "fame"
});

con.connect(function(err) {
  if (err) throw err;
  con.query("SELECT DISTINCT token FROM tokens", function (err, result, fields) {
    if (err) throw err;
    for (var i = 0; i < result.length; i++)
    {
    	deviceToken.push(result[i].token)    
    }
  });
});

setTimeout(myFunction, 5000);

function myFunction(){


// Set up apn with the APNs Auth Key
var apnProvider = new apn.Provider({  
     token: {
        key: 'apns.p8', // Path to the key p8 file
        keyId: '92BND42T3H', // The Key ID of the p8 file (available at https://developer.apple.com/account/ios/certificate/key)
        teamId: 'D93PPD94WK', // The Team ID of your Apple Developer Account (available at https://developer.apple.com/account/#/membership/)
    },
    production: true // Set to true if sending a notification to a production iOS app
});

console.log(deviceToken)

// Prepare a new notification
var notification = new apn.Notification();

// Specify your iOS app's Bundle ID (accessible within the project editor)
notification.topic = 'com.mschrage.fameshow';

// Set expiration to 1 hour from now (in case device is offline)
notification.expiry = Math.floor(Date.now() / 1000) + 3600;

// Set app badge indicator
//notification.badge = 3;

// Play ping.aiff sound when the notification is received
notification.sound = 'ping.aiff';

// Display the following message (the actual notification text, supports emoji)
notification.alert = process.argv[2];

// Send any extra payload data with the notification which will be accessible to your app in didReceiveRemoteNotification
notification.payload = {id: 123};

// Actually send the notification
apnProvider.send(notification, deviceToken).then(function(result) {  
    // Check the result for any failed devices
    console.log(result);
});

}