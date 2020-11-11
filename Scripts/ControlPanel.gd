extends Control




func _on_Main_gen_finished(room_data):
	$nLargeLabel.text = str(room_data["Failures"]["Large"])
	$nMediumLabel.text = str(room_data["Failures"]["Medium"])
	$nSmallLabel.text = str(room_data["Failures"]["Small"])
