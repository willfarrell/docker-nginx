var express = require('express');
var app = express();

app.get('/api', function (req, res) {
	setTimeout(function () {
		res.send({success:true});
	}, 100);

});

app.listen(3000);