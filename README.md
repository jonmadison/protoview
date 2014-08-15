To use this app you'll need to register for a Dropbox app key. Choose
"Drop-In". 

https://www.dropbox.com/developers/apps

Then, set up a URL scheme. From DropBox doc:

##Creating a URL scheme

The SDK coordinates with the Dropbox app (if it's installed) to simplify the auth process. But in order to smoothly hand the user back to your app, you need to add a unique URL scheme that Dropbox can call. You'll need to configure your project to add one:

**Click on your project** in the Project Navigator, choose the **Info** tab, expand the **URL Types** section at the bottom, and finally, press the + button.
In the **URL Schemes** enter db-APP_KEY (replacing APP_KEY with the key generated when you created your app).




