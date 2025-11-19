include:
  - users.github

roles:
  - docker
  - github-runner

github_runner:
  package:
    url: https://github.com/actions/runner/releases/download/v2.329.0/actions-runner-linux-x64-2.329.0.tar.gz
    hash: 194f1e1e4bd02f80b7e9633fc546084d8d4e19f3928a324d512ea53430102e1d
