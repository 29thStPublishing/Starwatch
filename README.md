# Installing Starwatch 
You can add Starwatch to an existing project pretty easily with these steps.

* Prepare your Mongo DB. 
   Set up a MongoDB of your choice, or sign up for a free hosted on http://www.mongolab.com. Note its connection info, and create a new collection called 'log'.
   

* Add the Starwatch-Resources files to your project.

* A few of them are not yet ARC-compliant. Add the -fno-objc-arc compilation flag to your Target's Build Phases under Compile Sources to the following files:
    - TwentyNineDBHelper.m
    - FMDatabase.m
    - FMResultSet.m
    - JSONKit.m
    
* Update the Starwatch-Resources/SWConstants.M file's mongo_settings dictionary values with the connectivity info you got in the first step.

* Add the following frameworks and libraries to your target's Build Phases -> Link Binary with Libraries'.  All are required.
      System Configuration framework
      CFNetwork framework
      libsqlite3.0.dylib
      
      
* The mongo-c-driver library requires this additional compiler flag to be set.  Under your target's Build Settings, click the Add Build Setting at the bottom.  The key for this setting will be "_MONGO_USE_GETADDRINFO" and the value will be 1.

 
* Do yourself a favor early on and turn on actions_to_stderr in your SWConstant.m file.  This will echo every action tracked by Starwatch to your stderr log for easy testing.  Otherwise, it happens in the background and you'd have to inspect the sqlite database to confirm record collection, which is really tough when you're working directly on a device.
      
Now your code is ready to begin using Starwatch.
      
      
# Starwatch: Basic
The easiest way to get started with Starwatch is to log the most basic actions.  The "Starwatch-Basic" project sends one hunk of information, called the "INFO" action. It will dump the time, what version of iOS the user is using, what type of device they have, their device timezone as a string, and the number of times they've opened the app.  

To use just the INFO packet in your project, include "SWCUtility.h" and insert the following snippets into your AppDelegate file.

in didFinishLaunchingWithOptions:
      
      /*** Starwatch BASIC ***/
      // This will make sure our DB's are in the correct place,
      // we've begun tracking actions against this unique device id,
      // and increments the number of times this user has opened the app.
      [SWCUtility begin];


      // Log the "INFO" action.
      // This method takes in a dictionary of your custom key-value pairs
      // and, along with general information about this device and user,
      // prepares to send it to the remote db.
      [SWCUtility logInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                               [NSString stringWithFormat:@"%d", [SWCUtility getNumOpens]],
                                                               nil]
                                                      forKeys:[NSArray arrayWithObjects:
                                                               @"num_opens",
                                                               nil]
                           ]
       ];
   
   
You also need to add something into the Enter Background method so that the data is actually sent.  I've added this into applicationDidEnterBackground:
      /*** Starwatch BASIC ***/
      [SWCUtility send_data];
   
   
   
To test, confirm your actions_to_stderr in SWConstants is set to YES, and when you open or close the app in the simulator or on a device, you should see info actions logged.  Example:

      2012-10-13 17:24:04.406 Starwatch-Plain[7959:11303] 
      [SWCUtility] {"name":"","action":"info","metadata":"{\"app_version\":\"1.0\",\"device\":\"iPad Simulator\",\"device_version\":\"iPad Simulator\",\"timezone\":\"America/New_York\",\"ios\":\"6.0\",\"num_opens\":\"2\"}","global_id":""}
   
When you minimize the app in the simulator or device (NOT by Stopping the running app in Xcode), it will trigger the send-data action.  Turn on sending of data by editing the send_stats value in SWConstants and look at your Mongo database to ensure you're collecting data.  Read "Parsing Collected Data" to work with the data you've collected.


   
   
   
# Starwatch: Advanced

   * ADD THE METHODS TO YOUR CODE.

      * In the App Delegate, add to the top:

      `#import "StarWatchDatastoreUtility.h"
      #import "SWCUtility.h"`

      * In didFinishLaunchingWithOptions, add:

         `// Fire up the stats engine and log the action of booting up.
         [StarWatchDatastoreUtility setupDatabaseAndIdentifier];
         [SWCUtility logAppStart];`

      * in applicationWillResignActive, add:
         `[SWCUtility logAppActive];`

      * in applicationDidEnterBackground, add:
         `[SWCUtility logAppEnd];`
      
then, use the SW* controllers instead of the core controllers.



# Parsing Collected Data and Presenting the Results
The `web_app/` folder is a python application that runs the tornado webserver on your local machine.  Installing tornado and pymongo is straightforward (`easy_install tornado`; `easy_install pymongo`), but if you haven't run this stack locally through virtualenv's and such, I recommend running https://github.com/nataliepo/HelloTornado just to test that your environment is ready.

## 
## Initializing
First, copy the `web_app/settings.py.default` file to settings.py.  Then, edit the `settings.py` file to reflect your mongodb settings, particularly in the MONGO_SETTINGS section.  The script should create the Collection definitions (session, view, device, feedback, etc) if they don't already exist.



## Info / "Basic" parsing
The `parse_logs.py` python script will aggregate unique device information collected and place it in your devices collection on mongo so that the webapp can present it for you.

To parse just the info logs, which is what was used in the Starwatch-Basic project, run this:
      python parse_log.py info
      
This sets a flag in each log record that the log has been seen so it won't be re-evaluated.  If you ever want to clear the info logs you've seen and re-parse the data, 
      python parse_log.py info-purge
will safely mark all logs of action INFO as not being seen so you can run parse_log.py info on it again to recollect the data.


## Advanced Parsing
We'll be releasing more parsing methods soon! (We need to test this a bit more, then document how it works, since it's very specialized to our platform.)



# License
Copyright © 2012, 29th Street Publishing, and Distributed under
the Artistic License.
