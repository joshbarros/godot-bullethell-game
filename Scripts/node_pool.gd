extends Node2D

@export var node_scene : PackedScene
var cached_nodes : Array[Node2D]

## Create a new node instance and add it to the pool.
## Instantiates from node_scene, adds to cached_nodes array,
## and adds to scene tree with deferred call (safe for physics).
## @return Node2D: The newly created node instance
func _create_new() -> Node2D:
	var node = node_scene.instantiate()
	cached_nodes.append(node)
	get_tree().get_root().add_child.call_deferred(node)
	return node

## Get a node from the pool, reusing hidden nodes or creating new ones.
## Searches cached_nodes for a hidden node to reuse (object pooling).
## If all nodes are active, creates a new one via _create_new().
## @return Node2D: A ready-to-use node (either recycled or new)
func spawn() -> Node2D:
	for node in cached_nodes:
		if node.visible == false:
			node.visible = true
			return node

	return _create_new()
