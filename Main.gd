extends Node

var threads = []
var num_threads = 3
var semaphore = Semaphore.new()

func _ready() -> void:	
	for i in num_threads:
		var thread = Thread.new()
		threads.push_back(thread)
		
	for i in num_threads:
		threads[i].start(self, "do_thing")


func do_thing():
	print("waiting") 
	semaphore.wait()
	print("did thing") 
	

func _input(event):
	if event.is_action_pressed("ui_accept"):
		semaphore.post()


func _exit_tree():
	for i in num_threads:
		semaphore.post()
		threads[i].wait_to_finish()
