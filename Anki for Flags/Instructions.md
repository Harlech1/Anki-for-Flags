# Adding Flag Images to Your Xcode Project

## Steps to Add Flag Images:

1. **Open your Xcode project**
2. **In the Project Navigator** (left sidebar), right-click on "Anki for Flags" folder
3. **Select "Add Files to 'Anki for Flags'"**
4. **Navigate to your project directory**
5. **Select all the .png flag files** (they're in the main "Anki for Flags" folder)
6. **Make sure "Add to target" is checked** for your app target
7. **Click "Add"**

## Alternative: Add via Assets Catalog

1. **Open Assets.xcassets** in Xcode
2. **Right-click in the empty area** and select "New Image Set"
3. **Name it after the flag code** (e.g., "us", "ca", "fr")
4. **Drag the corresponding .png file** into the image well
5. **Repeat for all flags**

## File Locations:
All flag PNG files are already copied to your main project directory:
`/Users/turkerkizilcik/Desktop/XCode Projects/Türker Coding/Anki for Flags/Anki for Flags/`

The app will automatically load and display the flags once they're properly added to the Xcode project bundle.