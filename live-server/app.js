var express = require('express');
var app = express();
var server = require('http').Server(app)
var io = require('socket.io')(server)
var execPhp = require('exec-php');
var apn = require('apn');
const exec = require('child_process').exec;

app.use(express.static(__dirname + '/public'));
app.set('views', __dirname + '/public/views');
app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

server.listen(process.env.PORT  || 3000)

var rooms = {}
var map_users = []
var streamer_users = []
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
var users_authenticated = {}
var showCounter = false
var upnext_queue = false
var queueupnext = ""

function getKeyByValue(object, value) 
{
  return Object.keys(object).find(key => object[key] === value);
}

function countUnique(iterable) 
{
  return new Set(iterable).size;
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

  potentialStreamers = streamer_users.slice()

  var winner = Math.floor(Math.random() * Math.floor(potentialStreamers.length))
  var winnerId = potentialStreamers.splice(winner)[0]

  var upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length))
  upNextId = potentialStreamers.splice(upNext)[0]

  nextExists = true

  io.sockets.emit('is_dead');
  io.sockets.connected[winnerId].emit("winner");
  io.sockets.connected[upNextId].emit("up_next");

  showCounter = true

  setTimeout(myFunction, 5000);

  function myFunction(){

    streamId = winnerId

    io.sockets.emit('new_room', idToRoom[winnerId])

    res.send("Winner: " + winnerId + ", Up next: " + upNextId);

  }

})

io.on('connection', function(socket) {

  users_authenticated[socket.id] = false
  map_users.push(socket.id)
  console.log(map_users)

  viewerCounter = countUnique(map_users)*10 + additionalViewers

  if (viewerCounter < 0)
  {
    viewerCounter = 0 + additionalViewers
  }

  socket.on('register_user', function(username, mbps, token) {

    idToUser[socket.id] = username
    idToMbps[socket.id] = mbps

    if (token == "welcometothefameshow")
    {
      users_authenticated[socket.id] = true;
    }

    console.log(idToUser)

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

  socket.on('toggle', function(streamer) {

    if (streamer === true)
    {
      var iterations = Math.round(idToMbps[socket.id])

      if (iterations < 1)
      {
        iterations = 1
      }

      for (var i = 0; i < iterations; i++)
      {
        streamer_users.push(socket.id)
      }
    }
    else
    {
      streamer_users = streamer_users.filter(a => a !== socket.id)
    }

  })

  socket.on('disconnect', function() {

    streamer_users = streamer_users.filter(a => a !== socket.id)
    map_users = map_users.filter(a => a !== socket.id)

    console.log(map_users)

    console.log('disconnect: ', idToUser[socket.id])

    // check if user has been queued as up next
    if (upnext_queue === true)
    {
      if (queueupnext == socket.id)
      {
        upnext_queue = false
        queueupnext = ""
      }
    }

    // check if user is up next

    if (upNextId == socket.id)
    {

      var potentialStreamers = streamer_users.slice(); 

      streamer_users = streamer_users.filter(a => a !== streamId)

      upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
      upNextId = potentialStreamers.splice(upNext)[0];

      io.sockets.connected[upNextId].emit("up_next");

      console.log(upNextId + " is up next.")

    }

    // check if user is streaming rn

    if (streamId == socket.id)
    {
      var potentialStreamers = streamer_users.slice(); // temporary

      potentialStreamers = potentialStreamers.filter(a => a !== streamId)

      streamId = upNextId

      potentialStreamers = potentialStreamers.filter(a => a !== streamId)

      io.sockets.connected[streamId].emit("is_live");

      // tell everybody what the new room is
      io.sockets.emit('new_room', streamRoom)

      console.log(streamId + " is streaming.")

      console.log(potentialStreamers)

      upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
      upNextId = potentialStreamers.splice(upNext)[0];

      io.sockets.connected[upNextId].emit("up_next");

      console.log(upNextId + " is up next.")

      totalTime = 0
      voteCounter = 0
      counter = INTERVAL
    }

    viewerCounter = countUnique(map_users)*10 + additionalViewers

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

      });
    });

  })

  setTimeout(function()
  { 

    if (!users_authenticated[socket.id])
    {
      socket.disconnect()
    }

  }, 5000);

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

        io.sockets.emit('tick', viewerCounter, voteCounter, counter, percentage, showCounter)

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

                  var potentialStreamers = streamer_users.slice(); // temporary

                  potentialStreamers = potentialStreamers.filter(a => a !== streamId)

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

                  potentialStreamers = potentialStreamers.filter(a => a !== streamId)

                  io.sockets.connected[streamId].emit("is_live");

                  // 5 second wait here.

                  // tell everybody what the new room is
                  io.sockets.emit('new_room', streamRoom)

                  console.log(streamId + " is streaming.")

                  console.log(potentialStreamers)

                if (upnext_queue === true)
                {
                  upNextId = queueupnext

                  io.sockets.connected[upNextId].emit("up_next");

                  console.log(upNextId + " is up next.")

                  totalTime = 0

                  upnext_queue = false
                }
                else
                {

                  upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
                  upNextId = potentialStreamers.splice(upNext)[0];

                  io.sockets.connected[upNextId].emit("up_next");

                  console.log(upNextId + " is up next.")

                  totalTime = 0
                }
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

  var potentialStreamers = streamer_users.slice(); // temporary

  potentialStreamers = potentialStreamers.filter(a => a !== streamId)
  potentialStreamers = potentialStreamers.filter(a => a !== upNextId)

  console.log(potentialStreamers)

  io.sockets.connected[upNextId].emit("is_dead")

  io.sockets.connected[upNextId].emit('new_room', streamRoom)

  upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
  upNextId = potentialStreamers.splice(upNext)[0];

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

    var potentialStreamers = streamer_users.slice(); // temporary

    potentialStreamers = potentialStreamers.filter(a => a !== streamId)

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

    potentialStreamers = potentialStreamers.filter(a => a !== streamId)

    io.sockets.connected[streamId].emit("is_live");

    // tell everybody what the new room is
    io.sockets.emit('new_room', streamRoom)

    console.log(streamId + " is streaming.")

    console.log(potentialStreamers)

    upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
    upNextId = potentialStreamers.splice(upNext)[0];

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

app.get('/message', function(req, res) 
{

  io.sockets.emit('message', req.query.message)

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/messageupnext', function(req, res) 
{

  io.sockets.connected[upNextId].emit('message', req.query.message)

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/end', function(req, res) 
{

  io.sockets.emit('terminated', session)

  res.send("It's done, it's over :)")

})

app.get('/video', function(req, res) 
{

var yourscript = exec('sh video.sh '+req.query.video,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });
  
  rooms["thefameshow44"] = {"title": "thefameshow44", "key": "thefameshow44"}

  res.render("panel.html", { streaming: streamRoom, threshold: threshold });

})

app.get('/genesisupnext', function(req, res) 
{

  var potentialStreamers = streamer_users.slice(); // temporary

  upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
  upNextId = potentialStreamers.splice(upNext)[0];

  io.sockets.connected[upNextId].emit("up_next");

  console.log(upNextId + " is up next.")

  setTimeout(myFunction6, 3000);

  function myFunction6(){

    res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

  }

})

app.get('/genesisstart', function(req, res) 
{

    nextExists = true

    var potentialStreamers = streamer_users.slice(); // temporary

    streamId = upNextId

    potentialStreamers = potentialStreamers.filter(a => a !== streamId)

    io.sockets.connected[streamId].emit("is_live");

    // tell everybody what the new room is
    io.sockets.emit('new_room', streamRoom)

    console.log(streamId + " is streaming.")

    console.log(potentialStreamers)

    upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
    upNextId = potentialStreamers.splice(upNext)[0];

    io.sockets.connected[upNextId].emit("up_next");

    console.log(upNextId + " is up next.")

    totalTime = 0
    voteCounter = 0
    counter = INTERVAL
    showCounter = true

    setTimeout(myFunction3, 3000);

    function myFunction3(){

      res.render("panel.html", { streaming: idToRoom[upNextId], threshold: threshold });

    }

})

app.get('/intervideo', function(req, res) 
{

  // 500ms before counter hits 0
  var timeleft = (INTERVAL - counter) * 1000 - 500

  var length = parseInt(req.query.length) * 1000

  setTimeout(myFunction7, timeleft);

  function myFunction7(){

    if (percentage >= 1)
    {
      // person is still on
      res.send("Person got more time. <a href='http://vojtadrmota.com:3000/cpanel'>Go back to cPanel</a>.")
    }
    else
    {
      counter = 1000000 // make sure this is longer than the length of video
      showCounter = false

      randnum = parseInt(Math.random() * 1000)
      roomname = "thefameshow44" + randnum

      io.sockets.connected[streamId].emit("is_dead")

      var yourscript = exec('sh video2.sh '+req.query.video+' '+roomname,
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });

      io.sockets.emit('new_room', roomname)

      console.log("VIDEO LENGTH: "+length)

      setTimeout(myFunction8, length);

      function myFunction8(){

                var potentialStreamers = streamer_users.slice();

                streamId = upNextId

                potentialStreamers = potentialStreamers.filter(a => a !== streamId)

                io.sockets.connected[streamId].emit("is_live");

                // tell everybody what the new room is
                io.sockets.emit('new_room', streamRoom)

                console.log(streamId + " is streaming.")

                upNext = Math.floor(Math.random() * Math.floor(potentialStreamers.length));
                upNextId = potentialStreamers.splice(upNext)[0];

                io.sockets.connected[upNextId].emit("up_next");

                console.log(upNextId + " is up next.")

                totalTime = 0
                counter = INTERVAL
                percentage = 0
                showCounter = true

                res.send("Done. <a href='http://vojtadrmota.com:3000/cpanel'>Go back to cPanel</a>.")

      }

    }

  }

})

app.get('/seeconnections', function(req, res) 
{

  var connected_users = ""
  var connected_size = 0

  for (var key in idToUser) {
    connected_users += "<br>"+idToUser[key]+": "+key
    connected_size += 1
  }

  res.send("<h1>Connected Users</h1> #: "+connected_size+" " + connected_users + "<h1>Broadcasters</h1> #: "+streamer_users.length+"<br>" + streamer_users)

})

app.get('/queueupnext', function(req, res) 
{

  queueupnext = req.query.upnext
  upnext_queue = true

})

app.get('/mbps', function(req, res) 
{

  res.send(idToMbps)

})

console.log('listening on port 3000...')