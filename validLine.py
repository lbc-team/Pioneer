import sys

def isCodeLabel(line):
  if line.strip().startswith("```"):
    return True
  else:
    return False

def isPic(line):
  if "![" in line and "](" in line:
      return True

  return False

def countLine(filePath):
  validLines = 0;
  inCode = False;

  with open(filePath, 'r') as rfile:
    for line in rfile:

      if inCode:
        if isCodeLabel(line):
          inCode = not inCode
        pass
      elif isCodeLabel(line):
        inCode = not inCode
      elif isPic(line):
        pass
      elif len(line.strip()) > 1:
        validLines += 1;

  return validLines


if __name__ == "__main__":
  filePath = sys.argv[1]
  num = countLine(filePath)
  print (num);