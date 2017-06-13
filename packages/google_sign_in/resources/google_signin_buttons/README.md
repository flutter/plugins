#Fetch Images
The images were fetched from the branding guidelines. 

These instructions outline copying the button assets into the images folder here
1. Download the button assets on https://developers.google.com/identity/branding-guidelines.
2. unzip assets
3. cd into google_signin_buttons/ios
4. `brew install rename` - install renaming utility 
5. `find . -exec rename 's|_ios.*?\.|.|' {} +`
6. copy the 1.x to google_sign_buttons
7. copy 2x and 3x to the respective directories
