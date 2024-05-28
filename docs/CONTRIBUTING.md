# Contributing

Help us to make this project better by contributing. Whether it's new features, bug fixes, or simply improving documentation, your contributions are welcome. Please start with logging a _github issue_ or submit a _pull request_.

Before you contribute, please review these guidelines to help ensure a smooth process for everyone.

Thanks.

## Issue Reporting

- Please browse our existing issues (present in the issues tab of the repository main page) before logging new issues.
- Check that the issue has not already been fixed in the `main` branch.
- Open an issue with a descriptive title and a summary.
- Please be as clear and explicit as you can in your description of the problem.
- Please state the version you are using in the description.
- Include any relevant code in the issue summary.

## Pull Requests

- Read [how to properly contribute to open source projects on Github][1].
- Fork the project (if you are not part of the developer team).
- Create a new branch for your changes. Please name your branch in the following format: `<type>/<short-description>`. Where `<type>` can be `feature`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`. The `<short-description>` should be a short summary of the changes you made.
- Make sure your code is well-formatted and follows the project's coding style.
- Add tests for any new functionality.
- Make sure all tests pass before submitting your pull request.
- Write good commit messages based on the rules below.
- Use the same coding conventions as the rest of the project.
- Commit locally and push to your fork until you are happy with your contribution.
- Make sure to add tests and verify all the tests are passing when merging upstream.
- Don't bother adding an entry to the [Changelog][2] because it should be automatic generated based on the [Conventional Commits][3].
- Please add your name to the [CONTRIBUTORS.md][4] file. Adding your name to the [CONTRIBUTORS.md][4] file signifies agreement to all rights and reservations provided by the [License][5].
- [Squash related commits together][6].
- Open a [pull request][7].
- Write a extensive description of all the changes made on this Pull Request using the [DEFAULT_PR_MESSAGE.md][8] as template.
- The pull request will be reviewed by the community and merged by the project committers.

## Commits

We use semantic commits to keep a clear and organized commit history. A semantic commit message has the following format:

```
<type>!(<scope>): <subject>

<body>

<footer>
```


### Message subject (first line) 

The first line cannot be longer than 70 characters, the second line is always blank and other lines should be wrapped at 80 characters. The type and scope should always be lowercase as shown below.

- `<type>`: The type of the commit. Can be one of the following:
  - :sparkles: `feat`: A new feature for the user, not a new feature for build script
  - :bug: `fix`: A bug fix for the user, not a fix to a build script
  - :memo: `docs`: Documentation
  - :art: `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc; no production code change)
  - :recycle: `refactor`: A code change that neither fixes a bug nor adds a feature (example scopes: renaming a variable)
  - :rocket: `perf`: A code change that improves performance
  - :heavy_check_mark: `test`: Adding missing tests or correcting existing tests; no production code change
  - :hammer: `build`: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
  - :green_heart: `ci`: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
  - :shower: `chore`: Updating grunt tasks, tool changes, configuration changes, and changes to things that do not actually go into production
- `!` : If we add an exclamation mark after the type, we have a breaking change and will result in a SemVer major and it should be detailed at the `<footer>` (*optional*).
- `<scope>`: The scope of the commit, should be the name of the component that was changed (*optional*).
- `<subject>`: A short description of the changes made in the commit.

### Message Body `<body>` (*optional*)

- uses the imperative, present tense: “change” not “changed” nor “changes”
- includes motivation for the change and contrasts with previous behavior

### Message Footer `<footer>` (*optional*)

**Referencing issues #**

Closed issues should be listed on a separate line in the footer prefixed with "Closes" keyword like this:

```
Closes #234
```

or in the case of multiple issues:

```
Closes #123, #245, #992
```

**Breaking changes #**

All breaking changes have to be mentioned in footer with the description of the change, justification and migration notes.

```
BREAKING CHANGE:

`port-runner` command line option has changed to `runner-port`, so that it is
consistent with the configuration file syntax.

To migrate your project, change all the commands, where you use `--port-runner`
to `--runner-port`.
```

### Examples

Here is an example of a semantic commit message:

```
feat(header): Add new feature to header component

Long description can be found here, but it is not obligatory.

Tasks #1120, #1121
```

Other example:
```
fix(middleware): ensure Range headers adhere more closely to RFC 2616

Add one new dependency, use `range-parser` (Express dependency) to compute range. It is more well-tested in the wild.

Fixes #2310
```

Please make sure your commit messages adhere to this format.
The format of this commits are based on [this gist][9] and [this article][10].


### Seven Rules of a great Git commit message

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how

Please make sure to follow these 7 rules when writing your commit messages.

This rules are based on the artle [How to Write a Git Commit Message][11].

## Changelog

We use [Github Changelog Generator][12] to generate automatically the file [Changelog][2].

## Code of Conduct

We have a [Code of Conduct](CODE_OF_CONDUCT.md), please make sure you read and abide by it.

Thank you for contributing to this project!

[1]: http://gun.io/blog/how-to-github-fork-branch-and-pull-request
[2]: ./docs/CHANGELOG.md
[3]: https://www.conventionalcommits.org/
[4]: ./docs/CONTRIBUTORS.md
[5]: ./LICENSE
[6]: http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html
[7]: https://help.github.com/articles/using-pull-requests
[8]: ./docs/DEFAULT_PR_MESSAGE.md
[9]: https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716
[10]: http://karma-runner.github.io/1.0/dev/git-commit-msg.html
[11]: https://cbea.ms/git-commit/
[12]: https://github.com/github-changelog-generator/github-changelog-generator
