# feature_package

Creates an empty Dart workspace package with the shared feature folder
convention. It does not move or alter any live app screens or business logic.

```sh
fvm exec mason make feature_package --output-dir .
fvm dart run melos bootstrap
```

The Dart workspace uses `packages/*/*`, so newly generated feature packages
are discovered automatically.
