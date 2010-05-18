require 'simpleton'

Simpleton.configure do |config|
  config[:user] = "vladimir"
  config[:hosts] = ["li28-179.members.linode.com"]
  config[:directory] = "~/integrity"
  config[:repository] = "git://github.com/integrity/integrity.git"
  config[:commit] = "origin/master"
end

Simpleton.use Simpleton::Middleware::GitUpdater
Simpleton.run
