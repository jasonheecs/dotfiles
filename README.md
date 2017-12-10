[![Build Status](https://travis-ci.org/jasonheecs/dotfiles.svg?branch=master)](https://travis-ci.org/jasonheecs/dotfiles)

# Jason Hee's Dotfiles

This is a setup script I use to setup my macOS development machines. It does the following:
- backup existing dotfiles to the `~/.dotfiles_old` directory
- create symlinks to the following dotfiles in your user home directory:
    - git
    - shell

## Installation
```sh
$ git clone https://github.com/jasonheecs/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
$ chmod +x setup.sh
$ ./setup.sh
```

## Local Settings
`~/.gitconfig.local`

Use `~/.gitconfig.local` to store sensitive information such as the git user credentials, e.g.:
```
[user]
  name = Jason Hee
  email = jason@example.com
```

## Acknowledgments
My dotfiles are heavily inspired from these sources:
 - [Nick Plekhanov's Dotfiles](https://github.com/nicksp/dotfiles)
 - [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles)
 - [Paul's dotfiles](https://github.com/paulirish/dotfiles)
 - [Dotfiles (Nicolas Gallagher)](https://github.com/necolas/dotfiles)