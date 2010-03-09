## What is Simpleton?

Simpleton is a deployment micro-framework which aims to simplify and improve
the deployment of web applications. In this regard, it is in the same space
as Capistrano, Vlad the Deployer, and other similar tools.

Simpleton is written in Ruby, and relies on existing UNIX command-line tools
(`ssh`, `git`, etc.) to bring out the best of both worlds: a powerful DSL with
testable deployment scripts, and of proven tools that are available
(almost) everywhere.

## Example

Here's what a basic deployment script using Simpleton may look like:

    require 'simpleton'
    
    Simpleton.configure do |config|
      config[:commit] = "origin/master"
      config[:directory] = "/data/my_app"
    end
    
    Simpleton.use Simpleton::Middleware::GitUpdater
    Simpleton.use Proc.new {'echo "Finished at `date`. Enjoy!"'}
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

A Command Runner is an object that responds to `run`, taking two string arguments
representing a host to run the command on, and the command to be run. The default
Command Runner is `Simpleton::CommandRunners::System`, whose `run` method is
simply:

    def self.run(host, command)
      system("ssh", host, command)
    end

If you prefer another way of running commands on a remote host, check out the
other Command Runners that ship with Simpleton, or simply write your own!

### Workers

Workers are objects that perform the work for a single host in the
configuration. Each `Simpleton::Worker`, given an array of Middleware objects
and a Command Runner, constructs a list of commands by calling the Middleware
objects and then runs the constructed commands in the list through the
Command Runner.

Each worker runs in its own process, forked by the Simpleton framework, and
is isolated from problems that may arise while running commands on the other
hosts.

## Thanks

* To Dan Hodos, for the project name.