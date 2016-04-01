### sendSynchronous
###### A deprecation rollback for sendSynchronousRequest
=========

### About

This project provides a category on the `NSUrlSession` class that restores the ability to dispatch synchronous requests, after the existing synchronous networking API's were deprecated in iOS 9.

It can be used as drop-in replacement for existing `[NSUrlConnection sendSynchronousRequest: ...]` calls, allowing you to clean up any deprecation warnings in your existing codebase without having to fundamentally restructure your entire app.


### Getting Started

Just copy the source files into your iOS project.

That should be it.  Nothing fancy here.  

Though note that this code was written and tested against iOS 9.  Your mileage may vary on previous iOS versions.  However there's no reason to use this library with iOS versions prior to 9 in the first place.


### Usage

To use this category, you must do two things:

1.  Import the header file, like:<pre>
\#import "NSURLSession+SynchronousRequest.h"
</pre>  Note that you only need to do this within the classes that contain your networking code, naturally.

2.  Replace every instance of `[NSURLConnection sendSynchronousRequest:returningResponse:error]` in your code with calls to `[NSURLSession sendSynchronousRequest:returningResponse:error]`.  That's it.  None of your other code should need to be changed, and you can enjoy your freedom from deprecation warnings in XCode.


### Limitations

In keeping with the rationale behind Apple's decision to deprecate synchronous network requests (namely, that developers just plain can't be trusted to properly background their blocking I/O operations), this category will not allow you to create synchronous network requests on the main thread.  

If you're not properly backgrounding your network requests, you'll either need to start doing so, switch to using asynchronous API's, or if you're really set on doing it the wrong way, manually modify the category code to allow outbound requests on the main thread.


### FAQ

**_Why create sendSynchronous?_**<br />
For a few reasons:

1.  Apple chose to deprecate their own support for synchronous network requests as of iOS 9, and;
2.  I have a number of projects that use synchronous network requests, in the background, correctly, and;
3.  I don't feel rearchitecting preexisting, working, correct code to use async networking just because Apple thinks I should is a productive use of my time.

So in short, because of Apple's penchant for making breaking changes to their SDK with little to no regard to the headaches their changes cause developers.

**_Why should I use sendSynchronous?_**<br />
Use this category if you've got pre-existing code that relies upon synchronous network requests, are sick of seeing deprecation warnings in XCode, and/or don't feel like reworking your entire networking layer to be asynchronous.

**_Why shouldn't I use sendSynchronous?_**<br />
Don't use this category if you're not using synchronous network requests in an iOS app, or if you don't understand how to use them properly.  

Also if you're building a new app from scratch you should probably just use the asynchronous API's unless you've got a really compelling case for going synchronous.

**_Are there any limitations to what sendSynchronous can do?_**<br />
Yes, in its default state the category will not allow you to send a synchronous request from the main thread.  Which isn't something your app should be doing in the first place.

**_What is `setAllowAnySSLCert:`?_**<br />
A helper function for if you happen to need to talk to a server that doesn't have a proper/trusted SSL certificate.  Calling this with a value of 'true' will essentially disable certificate validation on network requests.

Obviously doing so is *incredibly* insecure, and you should *never* enable this option in any sort of production context.  However it can be useful when developing and debugging, for instance if you have to talk with a develoment API server that's using a self-signed SSL certificate.

Also note that this only works when you *don't* pass your own `NSURLSession` instances to `sendSynchronousRequest:...` (i.e. when *not* using the `inSession:` parameter).  

**_Isn't asynchronous networking just plain better?_**<br />
No, not really.  Or at least, not when compared to properly implemented synchronous networking.  Asynchonrous I/O and backgrounded synchronous I/O are effectively the same, although for some use-cases synchronous API's and control flows are more convenient to deal with programmatically.

So it's really a question of convenience vs. ease of shooting yourself in the foot.  Asynchronous networking makes it much harder to do the latter, but trades a bit of the former to get there.

Debates about pros and cons aside, at the end of the day developers are entitled to choose which approach they want, and it's not up to Apple to force everybody through the same pigeonhole.

### License

I'm of the opinion that when someone takes something valuable, like source code, and knowingly and willingly puts it somewhere where literally anyone in the world can view it and grab a copy for themselves, as I have done, they are giving their implicit consent for those people to do so and to use the code however they see fit.  I think the concept of "copyleft" is, quite frankly, borderline insane.  

Information wants to be free without reservation, and good things happen when we allow it to be.  But not everyone agrees with that philosophy, and larger organizations like seeing an "official" license, so I digress.

For the sake of simplicity, you may consider all sendSynchronous code to be licensed under the terms of the MIT license.  Or if you prefer, the Apache license.  Or CC BY.  Or any other permissive open-source license (the operative word there being "permissive").  Take your pick.  Basically use this code if you like, otherwise don't.
