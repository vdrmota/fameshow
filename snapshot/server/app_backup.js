var app = require('express')()
var server = require('http').Server(app)
var io = require('socket.io')(server)
var execPhp = require('exec-php');

server.listen(process.env.PORT  || 3000)

var rooms = {}
var usernames_sockets = {}
var map_users = []
var have_upvoted = []
var streamRoom = ""
var idToRoom = {}
var streamId = ""
var upNextId = ""
var nextExists = false
var potentialStreamers = []
var voteCounter = 0
var viewerCounter = 0
const INTERVAL = 10
var counter = INTERVAL
var totalTime = 0

app.get('/rooms', function(req, res) 
{

  var roomList = Object.keys(rooms).map(function(key) 
  {
    return rooms[key]
  })

  res.send(roomList)

})


app.get('/genesis', function(req, res) {

  potentialStreamers = map_users.slice()

  var winner = Math.floor(Math.random() * Math.floor(potentialStreamers.length))
  var winnerId = potentialStreamers.splice(winner, 1)[0]

  var upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length))
  upNextId = potentialStreamers.splice(upNext, 1)[0]

  nextExists = true

  io.sockets.emit('is_dead');
  io.sockets.connected[winnerId].emit("winner");
  io.sockets.connected[upNextId].emit("up_next");

  setTimeout(myFunction, 5000);

  function myFunction(){

    streamId = winnerId

    io.sockets.emit('new_room', idToRoom[winnerId])

    res.send("Winner: " + winnerId + ", Up next: " + upNextId);

  }

})

io.on('connection', function(socket) {

  map_users.push(socket.id)
  //usernames_sockets[socket.id] = username
  console.log(map_users)

  socket.on('create_room', function(room) {

    if (!room.key) {
      return
    }

    console.log('create room:', room)
    var roomKey = room.key
    rooms[roomKey] = room
    socket.roomKey = roomKey
    streamRoom = roomKey

    idToRoom[socket.id] = roomKey

    socket.join(roomKey)

    // store room in database
    execPhp('create.php', function(error, php, outprint)
    {
      php.my_function(roomKey, socket.id, function(err, result, output, printed)
      {
        console.log('created')
      });
    });

  })

  socket.on('close_room', function(roomKey) {

    console.log('close room:', roomKey)

    delete rooms[roomKey]

  })

  socket.on('disconnect', function() {

    console.log('disconnect:', socket.roomKey)

    index = map_users.indexOf(socket.id)
    if (index > -1)
    {
      map_users.splice(index, 1)
    }

    console.log(map_users)

    if (socket.roomKey) 
    {
      delete rooms[socket.roomKey]
    }
    else
    {
      viewerCounter--
    }

  })

  socket.on('join_room', function(roomKey) {

    console.log('join room:', roomKey)

    socket.join(roomKey)

    viewerCounter++

  })

  socket.on('upvote', function(roomKey) {

    // check if person has already upvoted in this INTERVAL

    if (!have_upvoted.includes(socket.id))
    {
      // user can upvote
      console.log('upvote:', roomKey)
      voteCounter++

      io.sockets.emit('upvote')

      have_upvoted.push(socket.id)
    }
    else
    {
      // user has already upvoted -- notify that user
      io.sockets.connected[socket.id].emit("already_upvoted");
    }

  })

  socket.on('comment', function(data) {
    console.log('comment:', data)
    io.sockets.emit('comment', data)
  })

})

setInterval(function() {

        var result2 = {"viewers": viewerCounter, "votes": voteCounter, "time": counter};

        if (counter == 0)
        {

          if (viewerCounter != 0 && (voteCounter / viewerCounter) >= 0.3)
          {
            // positive case
            counter = INTERVAL

            // reset votes
            voteCounter = 0

            totalTime += INTERVAL
          }
          else
          {
            // negative case
            counter = INTERVAL
            totalTime += INTERVAL

              if (nextExists === true)
              {

                var potentialStreamers = map_users.slice(); // temporary

                potentialStreamers.splice(potentialStreamers.indexOf(streamId), 1)

                io.sockets.connected[streamId].emit("is_dead")

                // store results in database
                execPhp('store.php', function(error, php, outprint)
                {
                  php.my_function(totalTime, streamId, function(err, result, output, printed)
                  {
                    console.log('stored')
                  });
                });

                console.log(streamId + " is out.")

                streamId = upNextId

                potentialStreamers.splice(potentialStreamers.indexOf(streamId), 1)

                io.sockets.connected[streamId].emit("is_live");

                // tell everybody what the new room is
                io.sockets.emit('new_room', streamRoom)

                console.log(streamId + " is streaming.")

                console.log(potentialStreamers)

                upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
                upNextId = potentialStreamers.splice(upNext, 1)[0];

                io.sockets.connected[upNextId].emit("up_next");

                console.log(upNextId + " is up next.")

                // reset votes and time
                voteCounter = 0
                totalTime = 0
              }
              else
              {
                // genesis hasn't been called yet
                console.log('GENESIS NOT CALLED')
              }
          }

          // reset upvotes
          have_upvoted = []
          
        }
        else
        {
          counter--;
        }

        result2 = JSON.stringify(result2)
        console.log(result2)

        io.sockets.emit('tick', viewerCounter, voteCounter, counter)

}, 1000);

console.log('listening on port 3000...')