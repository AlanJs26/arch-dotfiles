const commands = {
  "\\cfrac": [2, `($1)/($2)`],
  "\\frac": [2, `($1)/($2)`],
  "\\cancel": [1, `*1`],
  "\\text": [1, `$1`],
  "\\div": [0, `/`],
  "\\cdot": [0, `*`],
  "\\times": [0, `*`],
  "\\large": [0, ``],
  "\\log_": [2, `Math.log10($2)/Math.log10($1)`],
  "\\log": [1, `Math.log10($1)`],
  "\\arcsin": [1, `Math.asin($1)`],
  "\\sen": [1, `Math.sin($1*Math.PI/180)`],
  "\\arccos": [1, `Math.acos($1)`],
  "\\mod": [0, `%`],
  "\\sqrt": [1, `Math.sqrt($1)`],
  "\\pi": [0, `Math.PI`],
  "\\floor": [1, `Math.floor($1)`]
}

let globalVariables;

let wordCompatible = false

function findCmd(str, start) {
  let brackets = 1;
  let betweenBrackets = '';
  let end = 0;

  for (let i = start; i < str.length; i++) {

    if (str[i] == '}') {
      brackets -= 1;
    } else if (str[i] == '{') {
      brackets += 1;
    }

    if (brackets <= 0) {
      break;
    }

    betweenBrackets += str[i];
    end = i;
  }

  if (brackets > 0) return;

  return [betweenBrackets, end];
}

function latexToMath(line) {
  let currentIndex;
  while (true) {
    let brackets = [];

    let firstCmd = line.match(/\\.+?(?={|}|\\|\W|$)/gm);
    if (!firstCmd)
      break;
    firstCmd = firstCmd[0];

    let commandArgs = commands[firstCmd];
    if (!commandArgs) {
      line = line.replace(firstCmd, '');
      continue;
    }

    // console.log(firstCmd)

    if (commandArgs[0] != 0) {
      currentIndex = line.indexOf(firstCmd) + firstCmd.length + 1;

      for (let i = 0; i < commandArgs[0]; i++) {
        let betweenBrackets = findCmd(line, currentIndex);
        currentIndex = betweenBrackets[1] + (i == 0 ? 3 : 0);
        brackets.push(betweenBrackets[0]);
      }
      // currentIndex -= 1;

    }

    if (brackets.length != 0) {
      let text = commands[firstCmd][1];

      for (let [i, content] of brackets.entries()) {
        content = content.replace(/(?<=\^){(-?\d+)}/gm, '**$1')
        
        // console.log(content.replace(/(?<=\^){(-?\d+)}/gm, '$1'))

        text = text.replace('$' + (i + 1), content)
      }
      // console.log(line.substr(line.indexOf(firstCmd), currentIndex - line.indexOf(firstCmd) + (commandArgs[0] > 1 ? 2 : -1)))
      // console.log(line.indexOf(firstCmd))
      line = line.replace(line.substr(line.indexOf(firstCmd), currentIndex - line.indexOf(firstCmd) + (commandArgs[0] > 1 ? 2 : -1)), text);
      // console.log(line)
    } else {
      line = line.replace(firstCmd, commands[firstCmd][1]);
    }
  }

  return line;
}

function parseLine(subMath, variables) {
  let count = -1;
  for ([name, value] of Object.entries(variables)) {
    let regexString = `\(?<!^\)@\\[${name}\(:\(?<index>.+?\)\)?\\]\(\(?<args>.{1,3}\(?=!\)\)?\(?<calc>!\)\)?`
    let regex = new RegExp(regexString);
    let globalregex = new RegExp(regexString, 'g');
    count++;
    let realName = Object.keys(variables)[count]
    
    if (subMath.match(regex)) {
      let allVars = subMath.match(globalregex)
      
      for(let i = 0; i < allVars.length; i++){
        let outValue = variables[realName];
        let text = allVars[i]

        let index = subMath.match(regex).groups.index
        if(index){
          let indexes = index.split(',');
          let separator = indexes.length > 1 ? indexes[1] : '*';
  
          if(value.split(separator).length>0){
            outValue = variables[realName].split(separator)[parseInt(indexes[0])]
            // value = indexes.length
          }
  
        }
        if(subMath.match(regex).groups.calc){
          let args = subMath.match(regex).groups.args
          if(args){
            subMath = subMath.replace(text, parseLine(`\\calc{${outValue}}[${args}]`, variables)[0])
          }else{
            subMath = subMath.replace(text, parseLine(`\\calc{${outValue}}`, variables)[0])
          }
        }else{
          subMath = subMath.replace(text, outValue)
        }
      }
    }
  }

  let calcCmd = subMath.match(/\\calc\{/)
  if (calcCmd) {
    // subMath = subMath.replace(/\^{(-?[^\}]+)}/gm, '**($1)')
    // console.log(latexToMath(insideCalc))
    
    try {
      let calcCmd = [...subMath.matchAll(/\\calc{/gm)];
      let allCalcs = [];

      for(let calc of calcCmd){
        let calcCmdLastIndex = calc.index + calc[0].length
        let insideCalc = findCmd(subMath, calcCmdLastIndex)[0]
        let extra = subMath.substring(calcCmdLastIndex).match(/(?<=})\[.+?\]/)
        extra = extra ? extra[0] : ""
        // subMath=subMath[calcCmdLastIndex]
        allCalcs.push([`\\calc{${insideCalc}}`, insideCalc, extra]);
      }
      
      for(let calc of allCalcs){
        let args = calc[2].substring(1, calc[2].length-1).split(',')

        if(calc[2] != ''){
          if(args[0].search("raw") != -1){
            subMath = subMath.replace(calc[0]+calc[2], eval(calc[1]));
            continue;
          }
        }

        calc[1] = calc[1].replace(/\bsin\b/, 'Math.sin')
                         .replace(/\bsen\(\b/, 'Math.sin(Math.PI/180*')
                         .replace(/\bcos\b/, 'Math.cos')
                         .replace(/\^{(-?[^\}]+)}/gm, '**($1)')

        // calc[1].replace(',', '.')


        if(calc[2] != ""){
          let isCientific = args[0].search("d") != -1 ? true : false;

          if(isCientific){
            const splitAt = (x, index) => [x.slice(0, index), x.slice(index)]
            let evaluated = eval(latexToMath(calc[1]))
            let str = evaluated.toString();
            let delimiter = parseInt(args[0]) != NaN ? parseInt(args[0]) : 0;

            if(evaluated > 1){
              if(delimiter > 0){
                if(str.search(/\./) != -1){
                  let negative = str[0] == '-' ? true : false
                    if(negative)
                      str = str.substr(1)
                    
                  let add = str.split('.')[0].length > 3 ? str.search(/\./) - delimiter : 0
                    // console.log(str)
                    if(add != 0){
                      let noDot = str.replace('.', '')
                        let decimalSplit = splitAt(noDot,delimiter)
                        decimalSplit[1] = decimalSplit[1].substr(0,delimiter)
                        var res = `${negative ? '-' : ''}${decimalSplit.join('.')}*10^{${add}}`
                    }else{
                      var res = `${negative ? '-' : ''}${str.substring(0,str.search(/\./)+delimiter+1)}`
                    }
                }else{
                  let decimalSplit = splitAt(str, delimiter);
                  let rightNums = decimalSplit[1].match(/.*[^0](?=0)?/)
                  let zeros = decimalSplit[1].match(/0+$/)
                  let right = rightNums ? `,${rightNums}` : ''
                  // console.log(decimalSplit)
                  var res = `${decimalSplit[0]}${right}${rightNums ? `*10^{${decimalSplit[1].length}}` : (zeros ? `*10^{${zeros[0].length}}` : '')}`;
                }
              }else{
                if(str.search(/\./) != -1){
                  let delimiter = 2;
                    let negative = str[0] == '-' ? true : false
                    if(negative)
                      str = str.substr(1)
                    
                  let add = str.split('.')[0].length > 3 ? str.search(/\./) - delimiter : 0
                    // console.log(str)
                    if(add != 0){
                      let noDot = str.replace('.', '')
                        let decimalSplit = splitAt(noDot,delimiter)
                        var res = `${negative ? '-' : ''}${decimalSplit.join('.')}*10^{${add}}`
                    }else{
                      var res = `${negative ? '-' : ''}${str.substring(0,str.search(/\./)+delimiter+1)}`
                    }
                }else{
                  let firstZero = str.match(/0(?![^0])/)
                  if(firstZero){
                    let decimalSplit = splitAt(str, firstZero.index);
                    var res = `${decimalSplit[0]}*10^{${decimalSplit[1].length}}`;
                  }else{
                    var res = str
                  }
                }
              }
            }else if(1 > evaluated > 0){
              if(delimiter > 0){
                let negative = str[0] == "-" ? true : false
                let firstNums = str.match(/(?<=0|\.)[^0\.]/).index+delimiter
                let decimalSplit = splitAt(str, firstNums);
                let numOfZeros = decimalSplit[0].substr(negative ? 3 : 2)
                let right = decimalSplit[1].length > 0 ? `.${decimalSplit[1]}` : ''
                var res = `${negative ? "-" : ""}${parseInt(numOfZeros)}${right.substring(0,delimiter+1)}*10^{-${numOfZeros.toString().length}}`
              }else{
                let negative = str[0] == "-" ? true : false
                let firstNums = str.match(/(?<=0|\.)[^0\.]/).index
                let decimalSplit = splitAt(str, firstNums);
                let right = decimalSplit[1].match(/.+[^0](?=0)/) ? decimalSplit[1].match(/.+[^0](?=0)/)[0] : decimalSplit[1]
                let numOfZeros = decimalSplit[0].match(/0/g).length
                var res = `${negative ? "-" : ""}${right.substring(0, 5)}*10^{-${numOfZeros+right.length-1}}`
              }
            }
            if(res.match(/^[^@]/))
              res = res.replace(',', '.')

            subMath = subMath.replace(calc[0]+calc[2], res);
          }else{
            subMath = subMath.replace(calc[0]+calc[2], eval(latexToMath(calc[1])).toFixed(args[0]));
          }
        }else{
          subMath = subMath.replace(calc[0], parseFloat(eval(latexToMath(calc[1])).toFixed(10)).toString());
        }
      }
    } catch (e) {
      console.log(e)
    }
  }

  let beginVar = subMath.match(/^@\[(?<name>.+)](?<rendered>[^\s]{0,6})=(?<value>.+)(?<equals>\=*$)/)
  if (beginVar && beginVar.groups.equals.length == 0) {
    let value = beginVar.groups.value
    let newValue = value
    if(value.search('sel{') != -1){
      newValue = findCmd(value, value.search('sel{')+4)[0]
    }
    variables[beginVar.groups.name] = newValue
    if (beginVar.groups.rendered.length > 0) {
      subMath = subMath.replace(beginVar[0], `${beginVar.groups.rendered}=${value.replace(`\\sel{${newValue}}`, newValue)}`)
    } else {
      subMath = subMath.replace(beginVar[0], ``)
    }
  }

  return [subMath, variables];
}

function customParseMarkdown(markdown, outVars=false) {
  if(typeof markdown != 'string') return markdown

  let variables = {}

  let allMaths = [...markdown.matchAll(/\$\$.*?\$\$\.?/gms)];

  if (allMaths) {
    for (math of allMaths) {
      let parsed = math[0].match(/(?<=\$\$).*?(?=\$\$\.?)/gms)[0];
      let allSubMaths = [...parsed.matchAll(/^.+/gm)]

      for (subMath of allSubMaths) {
        subMath = subMath[0];
        oldSubMath = subMath;
        subMath = subMath.replace('¨¨','')

        let line = parseLine(subMath, variables)

        subMath = subMath.replace(/^(.+=)?(.+)==(\[(.*?)\])?$/gm, ($1, $2, $3, $4, $5) => {
          let out= $4 ? `\\boxed{\\calc{${$3}}${$5}}` : `\\calc{${$3}}`
          line=parseLine(`${$2??''}${$3}=${out}`, variables)
          variables=parseLine(`@[tmp]=\\calc{${$3}}`,variables)[1];
          return `${$2??''}${$3}=\\calc{${$3}}`
        })

        let nextLine = ''
        subMath = subMath.replace(/^(.+=)(.+)_=(\[(.*?)\])?$/gm, ($1, $2, $3, $4, $5) => {
          line = parseLine($2+$3, variables)
          nextLine = $4 ? `\\boxed{\\calc{${$3}}${$5}}` : `\\calc{${$3}}`
          nextLine=parseLine(nextLine, variables)[0];
          variables = parseLine(`@[tmp]=${nextLine}`,variables)[1];
          nextLine = $2+nextLine;
          return $2+$3
        })


        if(nextLine){
          // variables=subVariables
          parsed = parsed.replace(oldSubMath, line[0]+'\n'+nextLine);
        }else{
          parsed = parsed.replace(oldSubMath, line[0]);
          variables = line[1]
        }

      }

      markdown = markdown.replace(math[0], `${parsed}`);
    }
  }

  globalVariables = variables;

  if(outVars == true){
    return [markdown, variables];
  }else{
    return markdown;
  }

}

exports.onWillParseMarkdown = function (markdown, word=false) {
      wordCompatible = word

      //math
      let allMaths = [...markdown.matchAll(/\$\$.*?\$\$/gms)];

      allMaths = allMaths.map(item => {
        return [item[0], item.index]
      })

      if (allMaths) {
        for ([index, math] of allMaths.entries()) {

          let center = false;
          let codeblock = false;
          
          let parsed = math[0].match(/(?<=\$\$).*?(?=\$\$)/gms)[0];
          parsed = customParseMarkdown(`$$${parsed}$$`, true)[0]

          if (parsed.slice(0,2) == '^^') {
            center = true;
            parsed = '\n'+parsed.slice(2)
          }

          if (parsed[0] == '>') {
            codeblock = true;
            parsed = parsed.slice(1)
          }

          if (parsed[0] == '.') {
            parsed = parsed.slice(1)
          }

          if (parsed[0] == '!') {
            parsed = parsed.slice(1)
            markdown = markdown.replace(math[0], `$$${parsed}$$`);
            continue;
          }


          parsed = parsed.replace(/^\>/gm, '\\qquad ')

          if(codeblock){
            parsed = parsed.replace(/[^\s].*[^\s]/gm, ($0) => `>$${$0}$\\`);
          }else{
            parsed = parsed.replace(/[^\s].*[^\s]/gm, ($0) => `$${$0}$\n`);
          }
          
          let allsubmaths = [...parsed.matchAll(/\$.*?\$\\?/gm)];

          for([i, submath] of Object.entries(allsubmaths)){
            submath=submath[0]
            let newSubmath = submath

            try{
              for(i of submath.matchAll(/\\mcolor\{(.+?)\}\{/g)){
                newSubmath=newSubmath.replace(newSubmath.match(/\\mcolor\{(.+?)\}\{/)[0]+findCmd(newSubmath, newSubmath.match(/\\mcolor\{(.+?)\}\{/).index+newSubmath.match(/\\mcolor\{(.+?)\}\{/)[0].length)[0]+'}',
                `\\color{${newSubmath.match(/\\mcolor\{(.+?)\}\{/)[1]}}${findCmd(newSubmath, newSubmath.match(/\\mcolor\{(.+?)\}\{/).index+newSubmath.match(/\\mcolor\{(.+?)\}\{/)[0].length)[0]}\\color{a}`
                )
                // '$1}$2\\color{a}'
              }

              for(i of submath.matchAll(/\\floor\{/g)){
                newSubmath=newSubmath.replace('\\floor{'+findCmd(newSubmath, newSubmath.match(/\\floor\{/).index+7)[0]+'}',
                `\\text{floor}(${findCmd(newSubmath, newSubmath.match(/\\floor\{/).index+7)[0]})`
                )
                // '$1}$2\\color{a}'
              }

              for(i of submath.matchAll(/\\size\{(.+?)\}\{/g)){
                newSubmath=newSubmath.replace(newSubmath.match(/\\size\{(.+?)\}\{/)[0]+findCmd(newSubmath, newSubmath.match(/\\size\{(.+?)\}\{/).index+newSubmath.match(/\\size\{(.+?)\}\{/)[0].length)[0]+'}',
                `\\${newSubmath.match(/\\size\{(.+?)\}\{/)[1]} ${findCmd(newSubmath, newSubmath.match(/\\size\{(.+?)\}\{/).index+newSubmath.match(/\\size\{(.+?)\}\{/)[0].length)[0]}\\normalsize `
                )
                // '$1}$2\\color{a}'
              }
              if(i==allsubmaths.length-1 && codeblock){
                newSubmath=newSubmath.replace(/\$\\/, '$')
              }
              parsed = parsed.replace(submath, newSubmath)
            }catch(err){
              console.log(err)
            }

          }


          parsed = parsed.replace(/\=\=\=/gm, ' \\text{ -------- }')
                         .replace(/\$\\\\(¨¨)?\$$/gm, '$\\hspace{1mm}$')
                         .replace(/(?<!\.)\.\.(?!\.)/gm, '\\hspace{4px}')
                         .replace(/__/gm, '\\hspace{20px}')
                         .replace(/\\va\|(.*?)\|/gm, `\\begin{aligned} $1 \\end{aligned}`)
                         .replace(/\\v\|(.*?)\|/gm, `\\begin{gathered} $1 \\end{gathered}`)
                         .replace(/\\mod/gm, `\\text{ mod }`)
                         .replace(/\s\=-\s/gm, '\\equiv ')
                         .replace(/=~/gm, `\\approx`)
                         .replace(/\[\[(.+?)\]\]/gm, `\\boxed{$1}`)
                         .replace(/\bblue\b/gm,    `lightskyblue`)
                         .replace(/\bred\b/gm,     `tomato`)
                         .replace(/\bgreen\b/gm,   `darkseagreen`)
                         .replace(/\bmagenta\b/gm, `hotpink`)
                         .replace(/^\$\@(.+)(¨¨)?\$/gm, ($1, $2) => parseLine(`\\calc{${$2}}`, globalVariables)[0])
          
          if(wordCompatible){
            parsed = parsed.replace(/={3}\>/gm, '\\xRightarrow{\\hspace{6mm}}')
                           .replace(/-{3}\>/gm, '\\xrightarrow{\\hspace{6mm}}')
                           .replace(/--\>/gm, ' \\rightarrow ')
                           .replace(/\s-\>/gm, ' \\rightarrow ')
                           .replace(/\s=\>/gm, ' \\Rightarrow ')
                           .replace(/\s\<=\>/gm, ' \\Leftrightarrow ')
                           .replace(/\s\<==\>/gm, ' \\Longleftrightarrow ')
                           .replace(/\=\=\>/gm, ' \\Rightarrow ')
                           .replace(/\s\.\s/gm, '\\cdot ')
                           .replace(/\s∙\s/gm, '\\cdot ')
                           .replace(/\*/gm, '\\cdot ')
                           .replace(/\\cfrac/gm, '\\frac ')
          }else{
            parsed = parsed.replace(/={3}\>/gm, '\\xRightarrow{\\hspace{6mm}}')
                           .replace(/-{3}\>/gm, '\\xrightarrow{\\hspace{6mm}}')
                           .replace(/--\>/gm, '\\hspace{5mm}\\rightarrow\\hspace{5mm}')
                           .replace(/\s-\>/gm, '\\space\\rightarrow\\space')
                           .replace(/\s=\>/gm, '\\space\\Rightarrow\\space')
                           .replace(/\s\<=\>/gm, '\\space\\Leftrightarrow\\space')
                           .replace(/\s\<==\>/gm, '\\space\\Longleftrightarrow\\space')
                           .replace(/\=\=\>/gm, '\\hspace{5mm}\\Rightarrow\\hspace{5mm}')
                           .replace(/\s\.\s/gm, '\\cdot ')
                           .replace(/\*/gm, '\\cdot ')
          }

          markdown = markdown.replace(math[0], center ? `<center>${parsed}</center>` : `${parsed}`);

          
          let allInlineMaths = [...markdown.matchAll(/#\$[^\s].+?\$/gms)]
    
          for(let i = 0; i < allInlineMaths.length; i++){
            let item = allInlineMaths[i]
    
            let inlineMath = item[0].slice(2,-1)
    
            let parsed = parseLine(' '+inlineMath, globalVariables)
    
            let parsedInlineMath = parsed[0]
          
            markdown = markdown.replace(`#$${inlineMath}$`, parsedInlineMath)
          }
        }
      }
      

      // nonMath commands
      let nonMath = [...markdown.matchAll(/^(?!$)(?!.*(\$.*?\$)).+/gm)];
      
      for(let text of nonMath){
        let newText = text[0]

        let parseColor = (color) => {
          let replaceList = [
            ['blue', 'lightskyblue'],
            ['red', 'tomato'],
            ['green', 'darkseagreen'],
            ['magenta', 'hotpink'],
          ]

          let newColor = color

          for(let item of replaceList){
            newColor = newColor.replace(item[0], item[1])
          }

          return newColor
        }

        newText = newText
        .replace(/\(\[(\w+)\](.+?)\)/gm, ($0, $1, $2) => `<span style="color: ${parseColor($1)}">${$2}</span>`)
        .replace(/\_((\w|\d|[0-9])+)\_/gm, '<ins>$1</ins>')

        markdown = markdown.replace(text[0], newText);
      }
      

      //variables


      //images
      if (markdown.matchAll(/!\[(.*?)\]\((.*?)\)\{(.+)?\}/gm)) {
        let allImgs = [...markdown.matchAll(/!\[(.*?)\]\((.*?)\)\{(.+)?\}/gm)];

        for (img of allImgs) {
          let linkMd = `
${`[${img[1]}.md](${encodeURI(img[2])})`}
\`\`\`python {cmd hide output="markdown"}\n
import os\n
import re\n
from subprocess import PIPE, run\n
\n
text = '''
<input id="input" type="checkbox">\n
<h3><strong>+Veja mais</strong></h3>\n
<div class="collapse">\n
&&1
'''\n
batcmd = r'cat "&&2"'\n
def out(command):\n
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True, shell=True, check=True)\n
    return result.stdout\n
output = re.sub(r'\\\`{3}.+?\\\`{3}', '', out(batcmd), flags=re.DOTALL)\n
output = re.sub(r'^#\\s(.+)', '\<h1\>\\g\<1\>\<\/h1\>', output, flags=re.MULTILINE)\n
text = text.replace('&&1', output)\n
print(text)\n
\`\`\`
`

          if(img[2].indexOf(".md") != -1){
            linkMd = linkMd.replace('&&2', img[2].toString().replace('\\', '/'))

            markdown = markdown.replace(img[0], linkMd);
            continue
          }

          if(img[3].toString().length <= 0)
            continue

          let isCenter = img[3].split(',').length > 1;

          let output = `<img src="${img[2]}" width="${isCenter ? img[3].split(',')[0] : img[3]}">`;

          markdown = markdown.replace(img[0], isCenter ? `<center>${output}</center>` : output);
          // markdown = markdown.replace(img[0], "alan");          
        }
      }

      markdown = markdown.replace(/\\\(.*?\\\)/gm, ($0) => `$${$0.slice(2, -2)}$`);
      // markdown = markdown.replace(/\_([^\s])+\_/gm, `<ins>$1</ins>`);
      
      // title = '';
      // let match = markdown.match(/#\s(.+$)/m)
      
      // if(markdown[0]+markdown[1] == "# " && match){
        // title = match[1]
        // title = title.replace(":", "-")
        // let date = new Date;
        // let parsedDate = date.toLocaleDateString().replace(/\//g,"-");
        // markdown = `---
// title: ${title}
// lang: pt-BR
// output:
  // word_document:
        // path: ${`${title} - (${parsedDate}) Alan José 3D.docx`}
// ---\n`+markdown.substr(match[0].length)

      // }else if(markdown[0] != "-"){        
        // markdown = "---\noutput: word_document\n---\n"+markdown;
      // }

      
      
      //raw out
      // markdown = `\`\`\`\n${markdown.replace(/\`/g, '\'')}`


      return markdown
  
  } 


const args = process.argv.slice(2)

if(args.length == 0){
  console.log('provide a output file')
  process.exit()
}

fs = require('fs')

fs.readFile(args[0], 'utf8', (err, data) => {
  if(err) return console.error(err)   

  const newMarkdown = exports.onWillParseMarkdown(data)

  fs.writeFile('tmp.md', newMarkdown, function (err) {
    if (err) return console.error(err);
    
    console.log('successfully preprocessed markdown in tmp.md');
  });
})
