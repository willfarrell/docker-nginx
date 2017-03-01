var express = require('express');
var app = express();

app.get('/api/v1/ping', function (req, res) {
	res.send({
		success:true,
		uuid: req.get('X-Request-Id')
	});
});

app.listen(3000);