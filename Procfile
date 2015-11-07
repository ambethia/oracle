web: bundle exec thin start -R config.ru -p ${PORT:-5000} -e ${RACK_ENV:-development}
worker: bundle exec ruby server/main.rb
