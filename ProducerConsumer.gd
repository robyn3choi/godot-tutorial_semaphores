extends Node

var num_producers = 2
var num_consumers = 2
var max_array_size = 10
var sem_empty = Semaphore.new()
var sem_full = Semaphore.new()
var mutex = Mutex.new()
var buffer = []
var consumers = []
var producers = []
var should_exit = false
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	
	for i in num_producers:
		var thread = Thread.new()
		producers.push_back(thread)
		thread.start(self, "produce")
	for i in num_consumers:
		var thread = Thread.new()
		consumers.push_back(thread)
		thread.start(self, "consume")
		
	for i in max_array_size:
		sem_empty.post()
		

func produce():
	while (true):
		sem_empty.wait()
		if should_exit: break
		mutex.lock()
		
		# we don't actually to check buffer.size() after adding semaphores
		if buffer.size() < max_array_size:
			var x = rng.randi_range(0, 99)
			buffer.push_back(x)
			print(buffer)
		else:
			print("can't produce")
			
		mutex.unlock()
		sem_full.post()
		 
func consume():
	while (true):
		sem_full.wait()
		if should_exit: break
		mutex.lock()

		# we don't actually to check buffer.size() after adding semaphores
		if buffer.size() > 0:
			buffer.pop_front()
			print(buffer)
		else:
			print("can't consume")
			
		mutex.unlock()
		sem_empty.post()

func _exit_tree():
	should_exit = true
	
	for i in num_producers:
		sem_empty.post()
		
	for i in num_consumers:
		sem_full.post()
		
	for i in num_producers:
		producers[i].wait_to_finish()
	
	for i in num_consumers:
		consumers[i].wait_to_finish()
