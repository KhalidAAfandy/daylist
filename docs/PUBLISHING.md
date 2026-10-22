# Publish on GitHub

1. Run the checks in CONTRIBUTING.md.
2. Create an empty public GitHub repository named `daylist`. Leave the automatic
   README, license and gitignore options unchecked because these files exist here.
3. From the project directory run:

```sh
git init -b main
git add .
git diff --cached --stat
```

Review staged files, then create the first commit and connect your repository:

```sh
git commit -m "Initial release of Daylist"
git remote add origin https://github.com/YOUR_USERNAME/daylist.git
git push -u origin main
```

Replace YOUR_USERNAME with your GitHub username. Check the Actions tab after
pushing; the workflow validates formatting, analysis, tests and the web build.
A downloadable web artifact is attached to successful runs. This does not deploy
a public website.

Suggested description: A calm, local-first Flutter task manager with search,
filters and on-device persistence.

Suggested topics: flutter, dart, todo-app, local-first, open-source.

The code is MIT licensed. Dependencies retain their own licenses; Flutter's
license registry is available through `showLicensePage` if distributing an app.
Native Android and iOS builds require their own toolchains and have not been
validated by the web CI workflow.
