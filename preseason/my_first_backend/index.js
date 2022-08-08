const express = require('express')
const basicAuth = require('express-basic-auth')
const app = express()


const port = 3000

let songs = ["Ac-cent-tchu-ate the Positive", "Accidents Will Happen", "Ad-Lib Blues" , "Ain't Cha Ever Comin' Back?", "Air For English Horn", "All I Need is the Girl", "All the Way Home", "All This and Heaven Too", "All Through the Day", "And Then You Kissed Me", "Anytime, Anywhere", "Any Time at All", "The Beautiful Strangers", "Before the Music Ends", "The Best of Everything", "Bonita", "The Boys Night Out", "But None Like You", "Collegiate" , "The Charm of You" ]

let wives = [" Barbara Sinatra", "Ava Gardner", "Mia Farrow", "Nancy Barbato"]

const random = Math.floor(Math.random() * songs.length)


app.get('/', (req,res) => {
    res.send(songs[random])
})

app.get('/birth_date', (req,res) => {
    res.send("December 12, 1915")
})

app.get('/wives', (req,res) => {
    res.send(wives)
})

app.get('/picture', (req,res) => {
    res.sendFile("C:\\Users\\Connor\\Qwasar\\my_first_backend\\Frank_Sinatra2,_Pal_Joey.jpg") // this needs to have a filepath for docode to work correctly
})

app.get('/public', (req,res) => {
    res.send("Everyone can see this page")
})

app.get('/private', (req,res) => {
    app.use(basicAuth({
        users: {'admin' : 'admin'},
        challenge: true,
    }))

    res.send("Welcome, authenticated client")

})

app.listen(port, () =>{
    console.log(`listening on port ${port}`)
})