# CONTRIBUTING

Please submit changes to the main branch, and make sure your code is willing to comply with MIT style.

## About development

The repo is manage by [melos][], so you need to install it first.

```bash
dart pub global activate melos
```

Then you can run `melos bootstrap` to init the repo.

```bash
melos bootstrap
```

And run:

```bash
melos run get
```

to get all dependencies.

[melos]: https://melos.invertase.dev

## About document

### About README

All packages use the same README file.

All changes need to be put into the README in the root directory and the `melos run cp_files` command needs to be run to synchronize the documentation.

### About CHANGELOG

The CHANGELOG for each package will use `melos` to manage it.

Please don't change CHANGELOG manually.

All changes will read from the git commit log and automatically generate the CHANGELOG.

Admins can use `melos version` to generate when before release.

We need add type for the git commit message, like `feat: provide a new feature`.

The type can be `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `revert`.

See [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for more information.

Also see it in [angular](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#type).

## Publish packages to pub.dev for admins

Admins can use `melos version` to generate the version and publish it.

1. Run `melos version` to generate the version. Or use `melos version --yes` to skip the version prompt.
2. Publish, have two ways:
   1. Run `melos publish` to publish the packages.
   2. Create a new release in GitHub, the GitHub Action will publish the packages.
