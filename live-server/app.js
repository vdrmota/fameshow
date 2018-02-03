var app = require('express')()
var server = require('http').Server(app)
var io = require('socket.io')(server)
var execPhp = require('exec-php');

server.listen(process.env.PORT  || 3000)

app.get('/rooms', function(req, res) {
  var roomList = Object.keys(rooms).map(function(key) {
    return rooms[key]
  })
  res.send(roomList)
})

var rooms = {}

io.on('connection', function(socket) {

  socket.on('create_room', function(room) {
    if (!room.key) {
      return
    }
    console.log('create room:', room)
    var roomKey = room.key
    rooms[roomKey] = room
    socket.roomKey = roomKey
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

    // if this is true then the broadcaster left
    if (socket.roomKey) 
    {
      delete rooms[socket.roomKey]
    }

  })

  socket.on('leave', function(roomKey) {
    console.log('leave:')

      // remove viewer
      execPhp('remove_viewer.php', function(error, php, outprint)
      {
      php.my_function(roomKey, function(err, result, output, printed)
      {
        console.log('removed')
      });
      });
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

console.log('listening on port 3000...')