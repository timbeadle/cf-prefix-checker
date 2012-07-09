component 
{

	/*public prefixchecker function init2(required string filePath) {
		variables.myfile = fileOpen(arguments.filePath, "read");
		variables.lines = [];
		while(not fileisEOF(variables.myfile)) {
			arrayAppend(variables.lines, fileReadLine(variables.myfile));
		}
		fileClose(myfile);
		return this;
	}*/
	
	public prefixchecker function init() {
		return this;
	}
	
	public array function arrayMerge(required array array1, required array array2) {
		for(var i = 1; i lte arrayLen(array2); i = i + 1) {
			arrayAppend(array1, array2[i]);
		}
		return array1;
	}
	
	private array function comparePrefixArrays(required array prefixArray1, required array prefixArray2, required string message) {
	
		var prefixedViolations = {};
		var prefixManifest = {};
		var violations = "";
	
		for (var i = 1; i lte arrayLen(arguments.prefixArray1); i = i + 1) {
		
			if (not structKeyExists(prefixedViolations, arguments.prefixArray1[i].prefix)) {
				structInsert(prefixedViolations, arguments.prefixArray1[i].prefix, []);
			}
		
			for (var j = 1; j lte arraylen(arguments.prefixArray2); j = j + 1) {
				
				// Key not found
				var formattedMessage = replaceList(arguments.message, '{1},{2}', "#arguments.prefixArray1[i].lineNumber#,#arguments.prefixArray1[i].prefix#");
				if (arrayLen(structFindValue(arguments.prefixArray2[j], arguments.prefixArray1[i].prefix, "all")) eq 0) {
					// Don't override a true value with false - true is sticky
					if (not structKeyExists(prefixManifest, arguments.prefixArray1[i].prefix) or not prefixManifest[arguments.prefixArray1[i].prefix]) {
						prefixManifest[arguments.prefixArray1[i].prefix] = false;
					}
				}
				else {
					prefixManifest[arguments.prefixArray1[i].prefix] = true;
				}
				//arrayAppend(prefixedViolations[arguments.prefixArray1[i].prefix], arguments.prefixArray1[i].prefix & ' found: ' & arrayLen(structFindValue(arguments.prefixArray2[j], arguments.prefixArray1[i].prefix, "all")));
				if (not arrayFind(prefixedViolations[arguments.prefixArray1[i].prefix], formattedMessage)) {
					arrayAppend(prefixedViolations[arguments.prefixArray1[i].prefix], formattedMessage);
				}
				
			}
			
		}
		
		// Delete the array of messages for prefix keys that *were* found
		for (prefix in prefixManifest) {
			if (prefixManifest[prefix]) {
				structDelete(prefixedViolations, prefix);
			}
			else {
				violations = listAppend(violations, arrayToList(prefixedViolations[prefix]));
			}
		}
		
		return listToArray(violations);
		
	}
	
	/**
	 * checkFile checks an individual file for cfimport prefix problems
	 */
	private array function checkFile(required string filePath) {
		var violations = [];
		var prefixes = [];
		var prefixUsages = [];
		var myfile = fileOpen(arguments.filePath, "read");
		var lineNumber = 1;
		
		while(not fileisEOF(myfile)) {
			var line = fileReadLine(myfile); // read line
			// Look for prefixes in cfimport tags
			var importSearch = refindNoCase("prefix=""([A-Za-z0-9]+)""", line, 1, true);
			if (arraylen(importSearch.pos) gt 1) {
				var importPrefix = mid(line, importSearch.pos[2], importSearch.len[2]);
				arrayAppend(prefixes, { prefix = importPrefix, lineNumber = lineNumber });
			}
			
			// Look for prefix usages
			var startPos = 1;
			while (startPos lte len(line)) {
				var namespaceSearch = refindNoCase("<([A-Za-z0-9]+):", line, startPos, true);
				if (arraylen(namespaceSearch.pos) gt 1) {
					var namespacePrefix = mid(line, namespaceSearch.pos[2], namespaceSearch.len[2]);
					arrayAppend(prefixUsages, { prefix = namespacePrefix, lineNumber = lineNumber });
					startPos = namespaceSearch.pos[2] + namespaceSearch.len[2];
				}
				else {
					startPos = len(line) + 1;
				}
			}
			lineNumber = lineNumber + 1;
		}
		
		fileClose(myfile);
		
		var unusedPrefixViolations = comparePrefixArrays(prefixes, prefixUsages, 'line {1}: declared namespace prefix "{2}" not used');
		var unimportedPrefixViolations = comparePrefixArrays(prefixUsages, prefixes, 'line {1}: used namespace prefix "{2}" not cfimported');
		
		violations = arrayMerge(unimportedPrefixViolations, unusedPrefixViolations);
		
		return violations;
	}
	
	/**
	 * check Checks a file or directory for cfimport prefix problems
	 * @param {String} filePath
	 * @author Tim Beadle
	 */
	public array function check(required string filePath, string format='dump') {
		var fileList = [];
		var violations = [];
		if (fileExists(arguments.filePath) or fileExists(expandPath(arguments.filePath))) {
			if (fileExists(arguments.filePath)) {
				fileList = [arguments.filePath];
			} else {
				fileList = [expandPath(arguments.filePath)];
			}
			
		}
		else if (directoryExists(arguments.filePath) or directoryExists(expandPath(arguments.filePath))) {
			
			try {
			
				if (directoryExists(arguments.filePath)) {
					//violations = [arguments.filePath];
					fileList = directoryList(arguments.filePath, true, 'path', '*.cfm');
				} else {
					fileList = directoryList(expandPath(arguments.filePath), true, 'path', '*.cfm');
				}
			
			} catch( Any e ) {
				violations = ['Foo'];
			}
			
		}
		else {
			//throw("File not found");
		}
		
		if (not arrayIsEmpty(fileList)) {
			// Loop over our file list, checking each file
			for (var i = 1; i lte arraylen(fileList); i = i + 1) {
				var fileViolations = checkFile(fileList[i]);
				if (not arrayIsEmpty(fileViolations)) {
					arrayAppend(violations, {filePath = fileList[i], violations = fileViolations });
				}
			}
		} 
		
		return violations;
		
	}
	
	
}
