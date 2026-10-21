Useful links:
 * [Make Home & End keys behave like Windows on Mac OS X](https://damieng.com/blog/2015/04/24/make-home-end-keys-behave-like-windows-on-mac-os-x/)

Unfortunately [KeyBindings](./Library/KeyBindings/) must be regular files, not symlinks. Original `GNU stow` tool doesn't support copying of the files. It seems that [xstow](https://xstow.sourceforge.net/) does have this feature, but there's no `brew` package for `xstow`. So it's required to copy [KeyBindings](./Library/KeyBindings/) files manually. The same limitation applies to keyboard layouts.

```
cp -rv ./Library/* ~/Library/
diff -srq ./Library/KeyBindings ~/Library/KeyBindings
diff -srq ./Library/Keyboard\ Layouts/ ~/Library/Keyboard\ Layouts
```
