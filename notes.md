# AssemBot Notes

## Version 0.2 - The Clean Up

Move to a class based approach? So you can have something like:

	var package= AssemBot.createPackage('package.js', {
		source: './source'
	});
	
	package.build(function(err, content, sourcemap){
		// Do want you want with it here.
	});
	
	package.fileList(function(filelist){
		// Array of file paths
	});
	
	// Override any settings you'd like
	package.set({
		minify: 1
	});

Would it be better to base it on the source folder instead of the output file(s)?

	var assembot= AssemBot.createFromSource('./source');
	
	assembot.assembleCss(function(err, css){
		// do with as you please, write to file, whatever.
	});
	assembot.assembleJs(function(err, js, srcMap){
		// Same here
	});
	assemby.assembleAll(function(err, css, js, sourcemap){
		// Whole shebang
	});


