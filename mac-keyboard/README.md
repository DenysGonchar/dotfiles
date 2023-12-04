Useful links:
 * [Make Home & End keys behave like Windows on Mac OS X](https://damieng.com/blog/2015/04/24/make-home-end-keys-behave-like-windows-on-mac-os-x/)
 * [Using hidutil to map macOS keyboard keys](https://rakhesh.com/mac/using-hidutil-to-map-macos-keyboard-keys/)
 * [hidutil key remapping generator for MacOS](https://hidutil-generator.netlify.app/)

Unfortunately [KeyBindings](./Library/KeyBindings/) must be regular files, not symlinks. Original `GNU stow` tool doesn't support copying of the files. It seems that [xstow](https://xstow.sourceforge.net/) does have this feature, but unfortunately there's no `brew` package for `xstow`
So it's required to copy [KeyBindings](./Library/KeyBindings/) files manually:
```
cp -rv ./Library/KeyBindings/* ~/Library/KeyBindings
diff -srq ./Library/KeyBindings ~/Library/KeyBindings
```
