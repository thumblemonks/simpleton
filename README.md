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

Here's what a basic deployment script using Simpleton may look like:

    require 'simpleton'
    
    Simpleton.configure do |config|
      config[:commit] = "origin/master"
      config[:directory] = "/data/my_app"
    end
    
    Simpleton.use Simpleton::Middleware::GitUpdater
    Simpleton.use Proc.new {'echo "Finished at `date` on the server."'}
    Simpleton.run

## Architecture

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
        %Q[git rev-parse #{configuration[:commit]}]
      end
    end

will lookup the commit-id of the commit to deploy on a remote host.

### Command Runners

A Command Runner is an object that responds to `run`, taking two string arguments:
a host to run the command on, and the command to be run. The default
Command Runner is `Simpleton::CommandRunners::Open3`, which outputs each command
that it runs, along with the resulting messages to standard output and standard
error, if there are any.

If you prefer another way of running commands on a remote host, check out the
other Command Runners that ship with Simpleton, or simply write your own!

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