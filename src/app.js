const fetch = require('node-fetch')

const express = require('express')
const app = express()
const port = process.env.PORT || 3000

// set the view engine to ejs
app.set('view engine', 'ejs');

// index page
app.get('/', async function(req, res) {
  const response = await fetch('https://ipinfo.io/json');
  const info = await response.text();
  const locationInfo = JSON.parse(info);

  res.render(__dirname + '/views/pages/index', locationInfo);
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`)
})
