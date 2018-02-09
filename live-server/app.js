var app = require('express')()
var server = require('http').Server(app)
var io = require('socket.io')(server)
var execPhp = require('exec-php');

server.listen(process.env.PORT  || 3000)

var rooms = {}
var map_users = []
var streamRoom = ""
var streamId = ""
var upNextRoom = ""
var upNextId = ""
var nextExists = false
var streamCounter = 0
var potentialStreamers = []
var voteCounter = 0;

app.get('/rooms', function(req, res) {
  var roomList = Object.keys(rooms).map(function(key) {
    return rooms[key]
  })
  res.send(roomList)
})

// function for genesis lottery
// will select next broadcaster and 'up-next' broadcaster
// have some timer that lets the next broadcaster know
app.get('/genesis', function(req, res) {
  // get array of all users who are willing to stream

  var potentialStreamers = map_users.slice();

  var winner = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
  var winnerId = potentialStreamers.splice(winner, 1)[0];
  var upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
  upNextId = potentialStreamers.splice(upNext, 1)[0];
  nextExists = true


  io.sockets.emit('is_dead');
  io.sockets.connected[winnerId].emit("winner");
  io.sockets.connected[upNextId].emit("up_next");

  res.send("Winner: " + winnerId + ", Up next: " + upNextId);

})

io.on('connection', function(socket) {

  map_users.push(socket.id)
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
    streamId = socket.id

    socket.join(roomKey)

    // create room for viewers and votes
    execPhp('create.php', function(error, php, outprint)
    {
      php.my_function(roomKey, function(err, result, output, printed)
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
    index = map_users.indexOf(socket.id);
    if (index > -1)
    {
      map_users.splice(index, 1);
    }
    console.log(map_users);

    // if this is true then the broadcaster left
    if (socket.roomKey) 
    {
      delete rooms[socket.roomKey]
    }
    else
    {
      execPhp('remove_viewer.php', function(error, php, outprint)
      {
      php.my_function(streamRoom, function(err, result, output, printed)
      {
        console.log('removed')
      });
      });
    }

  })

  socket.on('join_room', function(roomKey) {
    console.log('join room:', roomKey)
    socket.join(roomKey)

    // add viewer
    execPhp('add_viewer.php', function(error, php, outprint)
      {
      php.my_function(roomKey, function(err, result, output, printed)
      {
        console.log('added')
      });
    });
  })

  socket.on('upvote', function(roomKey) {
    console.log('upvote:', roomKey)
    voteCounter++
    io.to(roomKey).emit('upvote')

    // add upvote to database
    execPhp('upvote.php', function(error, php, outprint)
    {
      php.my_function(roomKey, function(err, result, output, printed)
      {
        console.log('sent')
      });
    });
  })

  socket.on('gift', function(data) {
    console.log('gift:', data)
    io.to(data.roomKey).emit('gift', data)
  })

  socket.on('comment', function(data) {
    console.log('comment:', data)
    io.to(data.roomKey).emit('comment', data)
  })

})

const INTERVAL = 30;
var counter = INTERVAL

setInterval(function() {
  // add upvote to database
  execPhp('retrieve.php', function(error, php, outprint)
  {
    php.my_function(streamRoom, function(err, result, output, printed)
    {
      if (err === false)
      {
        result = JSON.parse(result)
        var result2 = {"viewers": result.viewers, "votes": voteCounter, "time": counter};
        if (counter == 0)
        {

          if (result.viewers != 0 && (voteCounter / result.viewers) >= 0.3)
          {
            // positive case
            counter = INTERVAL;

            // reset votes
            voteCounter = 0
          }
          else
          {
            // negative case
            counter = INTERVAL;

            // lottery code
            // emit event to lottery winner
            // client-side handles switch to broadcast view
            // keep track of streamRoom

              if (nextExists === true)
              {
                io.sockets.connected[streamId].emit("is_dead");

                console.log(streamId + " is out.")

                streamId = upNextId

                io.sockets.connected[streamId].emit("is_live");

                console.log(streamId + " is streaming.")

                var potentialStreamers = map_users.slice(); // temporary
                console.log(map_users)
                upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
                upNextId = potentialStreamers.splice(upNext, 1)[0];

                io.sockets.connected[upNextId].emit("up_next");

                console.log(upNextId + " is up next.")

                // reset votes
                voteCounter = 0
              }
              else
              {
                // genesis hasn't been called yet
                console.log('GENESIS NOT CALLED')
              }
          }
          
        }
        else
        {
          counter--;
        }
        result2 = JSON.stringify(result2);
        console.log(result2)
        io.to(streamRoom).emit('tick', result.viewers, result.votes, counter)
      }
    });
  });
}, 1000);

console.log('listening on port 3000...')