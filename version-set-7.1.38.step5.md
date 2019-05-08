# version-set-7.1.38
## Step 5
- Launch the Xcode project `Miele_LXIV.xcodeproj` located in `SRC`

	-  If required, fixup *libjpeg*, *libpng*, *libtiff*. For older Miele-LXIV versions (7.1.38) you might get some missing files, shown in red in the Xcode project navigator. Using Finder, drag and drop the 3 libraries with the same name from the `BIN` directory where you just built them, to the Xcode project navigator panel, next to the items that show up in red:

		![step5](img/step5.png)

	1.  menu: "Product", "Scheme", "Edit Scheme...", "Run", "Info", "Build Configuration", select "Development", "Close"
	2. "PROJECT", "Info", Localization, remove all languages except "English - Development Language". Unselect the option "Delete localized resources files from disk".
	3. Select the `miele-lxiv` scheme.
	4. menu: "Product", "Build"

- If when you build the application you get some error with signing certificate, try removing the Signing Identity for the Development configuration:

	![codesign](img/codesign.png)
