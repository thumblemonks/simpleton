## What is Simpleton?

Simpleton is a deployment micro-framework which aims to simplify and improve
the deployment of web applications. In this regard, it is in the same space
as Capistrano, Vlad the Deployer, and other similar tools.

Simpleton is written in Ruby, and relies on existing UNIX command-line tools
(`ssh`, `git`, etc.) to bring out the best of both worlds: a powerful DSL with
testable deployment scripts, and of proven tools that are available
(almost) everywhere.

## Installation

    gem install simpleton

## Example

Here's what a basic deployment script using Simpleton can look like:

    require 'simpleton'
    
    Simpleton.configure do |config|
      config[:hosts] = ["host1", "host2"]
      config[:repository] = "git://github.com/fantastic/awesome.git"
      config[:commit] = "origin/master"
      config[:directory] = "/data/awesome"
    end
    
    Simpleton.use Simpleton::Middleware::GitUpdater
    Simpleton.use Proc.new {'echo "Finished at `date` on the server."'}
    Simpleton.run

The output you'd get would look something like this:

    [host1]< cd /data/awesome && git fetch && git reset --hard origin/master
    [host2]< cd /data/awesome && git fetch && git reset --hard origin/master
    [host1]> HEAD is now at 123abcs This is the best commit ever.
    [host1]< echo "Finished at `date` on the server."
    [host2]> HEAD is now at 123abcs This is the best commit ever.
    [host2]< echo "Finished at `date` on the server."
    [host1]> Finished at Wed Mar  31 04:31:51 UTC 2010 on the server.
    [host2]> Finished at Wed Mar  31 04:31:51 UTC 2010 on the server.

## Design

Simpleton is built on three basic ideas: *Middleware*, *Command Runners*,
and *Workers*.

### Middleware

A Middleware is an object that responds to `call`, taking as an argument
the Simpleton::Configuration hash. It returns a string, which is a command
that will be executed on a remote host.

For example, when the command from this middleware:

    Proc.new { %Q[echo "The time on the server is `date`"] }

is run, it will echo the current time on a remote host, and:

    class Something
      def self.call(configuration)
        "git rev-parse #{configuration[:commit]}"
      end
    end

will lookup the commit-id of the commit to deploy on a remote host.

### Command Runners

A Command Runner is an object that responds to `run`, taking two string arguments:
a location to run the command at, and the command to be run. The location is in
the standard SSH `[user@]hostname` format, so it can be just a host to run the
command and optionally include a specific user to run the command as.

The default Command Runner is `Simpleton::CommandRunners::Open3`, which displays
each command that it runs, along with the results of its standard output and
standard error streams.

If you prefer another way of running commands on a remote host, check out the
other Command Runner that ship with Simpleton (System), write your own.
It's simple!

### Workers

Workers are objects that perform the work for a single host in the
configuration. Given an array of Middleware objects and a Command Runner
each `Simpleton::Worker` constructs a list of commands by calling the Middleware
objects and then runs the list of constructed commands through the Command Runner.

Each worker runs in its own process, forked by the Simpleton framework, so it
is isolated from problems that may arise while running commands on the other
hosts.

## Dependencies

* Runtime: `none`
* Development
  * `riot`
  * `rr`

## Thanks

* __Dan Hodos__, for the project name.