.MODEL SMALL
.STACK 100H
.DATA
    inputString DB 100 DUP('$')               
    subString DB 100 DUP('$')
    vowelRemoved DB 100 DUP('$')              
    prompt1 DB 'Enter string: $'
    promptSub DB 'Enter substring: $'
    optionMsg DB 'Choose: 1-Consonant Count  2-Substring Check  3-Remove Vowels $'
    optionChoice DB 0
    countMsg DB 'Consonant count: $'
    foundMsg DB 'Substring found: Yes$'
    notFoundMsg DB 'Substring found: No$'
    resultMsg DB 'String without vowels: $'
    consonantCount DB 0

.CODE

consFreq MACRO inputString
    MOV SI, OFFSET inputString + 2       
    MOV CL,[inputString+1]     
    MOV consonantCount, 0                

count:
    MOV AL, [SI]                        
    CMP AL, 0DH                          
    JE endCount                         
    CALL consCheck                    
    CMP AL, 1                          
    JNE skipChar                        
    INC consonantCount                  
skipChar:
    INC SI                               
    DEC CL                              
    JNZ count                       
endCount:
ENDM

consCheck PROC
    CMP AL, 'A'
    JB notAlphabet                      
    CMP AL, 'Z'
    JA isLower                         
    CMP AL, 'A'
    JE notConsonant
    CMP AL, 'E'
    JE notConsonant
    CMP AL, 'I'
    JE notConsonant
    CMP AL, 'O'
    JE notConsonant
    CMP AL, 'U'
    JE notConsonant
    JMP consonantFound
isLower:
    CMP AL, 'a'
    JB notAlphabet                      
    CMP AL, 'z'
    JA notAlphabet                     
    CMP AL, 'a'
    JE notConsonant
    CMP AL, 'e'
    JE notConsonant
    CMP AL, 'i'
    JE notConsonant
    CMP AL, 'o'
    JE notConsonant
    CMP AL, 'u'
    JE notConsonant
consonantFound:
    MOV AL, 1                          
    RET
notConsonant:
    MOV AL, 0                          
    RET
notAlphabet:
    MOV AL, 0                         
    RET
consCheck ENDP
jmp END_PROGRAM

checkSubstring MACRO subString,inputString
    MOV SI, OFFSET inputString + 2    
    MOV DI, OFFSET subString + 2       
    MOV CL, [inputString + 1]           
    MOV DL, [subString + 1]           
    MOV AL, 0                         
    CMP DL, 0                         
    JE no_substring_found             

substring_check:
    MOV BH, DL                        
    PUSH CX                            
    MOV CH, CL                        
    MOV SI, OFFSET inputString + 2      
    MOV DI, OFFSET subString + 2     

find_substring_loop:
    MOV BL, [DI]                       
    MOV AL, [SI]                      
    CMP AL, BL                        
    JNE no_match                       
    INC DI                            
    INC SI                           
    DEC BH                            
    JNZ find_substring_loop           
    MOV AL, 1                         
    JMP substring_done

no_match:
    POP CX                           
    INC SI                            
    DEC CX                            
    CMP Cl, DL                         
    JAE substring_check              
    JMP no_substring_found            

no_substring_found:
    MOV AL, 0                         
    JMP substring_done

substring_done:
ENDM
jmp END_PROGRAM

removeVowels MACRO inputString
    MOV SI, OFFSET inputString + 2     
    MOV DI, OFFSET vowelRemoved         
    MOV CL, [inputString+1]   

removeLoop:
    MOV AL, [SI]                      
    CMP AL, 0DH                        
    JE endRemove                       
    CALL vowCheck                      
    CMP AL, 1                         
    JE SKIP_CHARac                        
    MOV AL, [SI]                       
    MOV [DI], AL                        
    INC DI                            
SKIP_CHARac:
    INC SI                              
    DEC CL                              
    JNZ removeLoop                    
endRemove:
    MOV [DI], '$'              
ENDM

vowCheck PROC
    CMP AL, 'A'
    JE vowelFound
    CMP AL, 'E'
    JE vowelFound
    CMP AL, 'I'
    JE vowelFound
    CMP AL, 'O'
    JE vowelFound
    CMP AL, 'U'
    JE vowelFound
    CMP AL, 'a'
    JE vowelFound
    CMP AL, 'e'
    JE vowelFound
    CMP AL, 'i'
    JE vowelFound
    CMP AL, 'o'
    JE vowelFound
    CMP AL, 'u'
    JE vowelFound
    MOV AL, 0                          
    RET
vowelFound:
    MOV AL, 1                          
    RET
vowCheck ENDP 

display MACRO msg
    MOV AH, 09H
    LEA DX, msg
    INT 21H     
ENDM

input MACRO
    MOV AH, 0AH
    LEA DX, inputString
    INT 21H
ENDM

START:
    MOV AX, @DATA
    MOV DS, AX

    display optionMsg             
    MOV AH, 01H
    INT 21H                       
    MOV optionChoice, AL
    MOV AH, 02H 
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    display prompt1               
    input mainString
    MOV AH, 02H 
    MOV DL, 0DH
    INT 21H
    MOV DL, 0AH
    INT 21H
    CMP optionChoice, '1'         
    JE consonant_task
    CMP optionChoice, '2'        
    JE substring_task
    CMP optionChoice, '3'         
    JE remove_vowel_task
    JMP END_PROGRAM

consonant_task:
    consFreq inputString
    display countMsg
    MOV AL, consonantCount
    ADD AL, '0'                         
    MOV DL, AL
    MOV AH, 02H
    INT 21H               
    JMP END_PROGRAM

substring_task:
    display promptSub                
    input subString                   
    checkSubstring subString,inputString                 
    CMP AL, 1                         
    JE substring_found               
    display notFoundMsg              
    JMP END_PROGRAM                   

substring_found:
    display foundMsg 
    JMP END_PROGRAM 
    
remove_vowel_task:
    removeVowels inputString                      
    display resultMsg                   
    MOV AH, 09H
    LEA DX, vowelRemoved
    INT 21H
    JMP END_PROGRAM

END_PROGRAM:
    MOV AH, 4CH
    INT 21H                      

END START