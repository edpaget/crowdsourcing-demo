require('coffee-script');
require('./server');
if (process.env.NODE_ENV == 'development') {
  require('./front-end/server');
}
