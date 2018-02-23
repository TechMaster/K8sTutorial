const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('<h1>Node.js Demo App</h1>'))
app.get('/test', (req, res) => res.send('test ok'))
app.listen(3000, () => console.log('Example app listening on port 3000!'))