var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index/index');
});

router.get('/land', function (req, res, next) {
  res.render('log-in/login');
});


module.exports = router;
