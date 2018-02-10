var express = require('express');
var app = express();
var server = require('http').Server(app)
var io = require('socket.io')(server)
var execPhp = require('exec-php');

app.use(express.static(__dirname + '/public'));
app.set('views', __dirname + '/public/views');
app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

server.listen(process.env.PORT  || 3000)

var rooms = {}
var usernames_sockets = {}
var map_users = []
var have_upvoted = []
var streamRoom = ""
var idToRoom = {}
var idToUser = {}
var idToMbps = {}
var streamId = ""
var upNextId = ""
var nextExists = false
var potentialStreamers = []
var voteCounter = 0
var viewerCounter = 0
const INTERVAL = 30
var counter = INTERVAL
var totalTime = 0
var percentage = 0
var additionalViewers = 0
var session = (new Date).getTime()
var threshold = 0.33

function getKeyByValue(object, value) {
  return Object.keys(object).find(key => object[key] === value);
}

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

  viewerCounter = (map_users.length - 1)*10 + additionalViewers

  if (viewerCounter < 0)
  {
    viewerCounter = 0 + additionalViewers
  }

  socket.on('register_user', function(username, mbps) {

    idToUser[socket.id] = username
    idToMbps[socket.id] = mbps

  })

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
      php.my_function(roomKey, socket.id, idToUser[socket.id], session, function(err, result, output, printed)
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

    viewerCounter = (map_users.length - 1)*10 + additionalViewers

    if (viewerCounter < 0)
    {
      viewerCounter = 0 + additionalViewers
    }

    if (socket.roomKey) 
    {
      delete rooms[socket.roomKey]
    }
    else
    {
      //viewerCounter--
    }

  })

  socket.on('join_room', function(roomKey) {

    console.log('join room:', roomKey)

    socket.join(roomKey)

    //viewerCounter++

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

  socket.on('subscribe', function(currentRoom) {

    console.log('subscribe')

    broadcaster = idToUser[getKeyByValue(idToRoom, currentRoom)]
    subscriber = idToUser[socket.id]

    // store room in database
    execPhp('subscribe.php', function(error, php, outprint)
    {
      php.my_function(broadcaster, subscriber, session, function(err, result, output, printed)
      {
        console.log(subsciber + ' subscribed to ' + broadcaster)
      });
    });

  })

})

setInterval(function() {

        if (viewerCounter != 0)
        {
          percentage = Math.abs((voteCounter / viewerCounter) / threshold)
        }
        else
        {
          percentage = 0
        }
        

        var result2 = {"viewers": viewerCounter, "votes": voteCounter, "time": counter, "%": percentage};
        result2 = JSON.stringify(result2)
        console.log(result2)
        io.sockets.emit('tick', viewerCounter, voteCounter, counter, percentage)

        if (counter == 0)
        {

          // reset votes
          voteCounter = 0

          if (viewerCounter != 0 && percentage >= 1)
          {
            // positive case
            counter = INTERVAL

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

}, 1000);

app.get('/cpanel', function(req, res) 
{

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

// gets a new up-next person

app.get('/next', function(req, res) 
{

  var potentialStreamers = map_users.slice(); // temporary

  potentialStreamers.splice(potentialStreamers.indexOf(streamId), 1)
  potentialStreamers.splice(potentialStreamers.indexOf(upNextId), 1)

  console.log(potentialStreamers)

  io.sockets.connected[upNextId].emit("is_dead")

  upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
  upNextId = potentialStreamers.splice(upNext, 1)[0];

  io.sockets.connected[upNextId].emit("up_next");

  console.log(upNextId + " is up next.")

  setTimeout(myFunction2, 3000);

  function myFunction2(){

    res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

  }
})

// promotes up-next to broadcaster and re-runs lottery

app.get('/promote', function(req, res) 
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

    totalTime = 0
    voteCounter = 0
    counter = INTERVAL

    setTimeout(myFunction3, 3000);

    function myFunction3(){

      res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

    }

})

app.get('/addvotes', function(req, res) 
{

  var votes = parseInt(req.query.votes)

  for (var i = 0; i < votes; i++)
  {
    console.log('upvote:', idToRoom[streamId])
    voteCounter++

    io.sockets.emit('upvote')
    setTimeout(myFunction4, 600);

    function myFunction4(){

    }
  }

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/addviewers', function(req, res) 
{

  oldAdditionalViewers = additionalViewers

  var viewers = parseInt(req.query.viewers)

  additionalViewers = viewers
  viewerCounter += additionalViewers - oldAdditionalViewers

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/threshold', function(req, res) 
{

  var newThreshold = parseFloat(req.query.threshold)

  threshold = newThreshold

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/end', function(req, res) 
{

  io.sockets.emit('terminated', session)

  res.send("It's done, it's over :)")

})

console.log('listening on port 3000...')