var execPhp = require('exec-php');
var payouts = {"vojtadrmota": 20, "mschrage":20 };

  //store payouts
  execPhp('store.php', function(error, php, outprint)
  {
    php.my_function(payouts, function(err, result, output, printed)
    {
      console.log(printed)
    });
  });