Emacs package to modify faces of symbols used by `prettify-symbols-mode'        
For package usage read comments from beginning of `preface-mode.el' file.       
It's pointless to write it here again.                                             
Package installation:                                                           
1) Copy preface-mode.el in any director from variable `load-path'. To see       
the variable content type `M-: load-path'. You can have your own                
directory in `load-path' symply creating anywhere a directory and add           
next epression in your .emacs file or your emacs init file:                     
(add-to-list 'load-path "path-to-directory").                                   
2) Add expression (require 'preface-mode) in your .emacs file or your           
emacs init file.                                                                
3) Reload emacs or type `M-x: load-file -> path-to-preface-mode.el'             
                                                                                
If you want only to test the package without any installation, simply           
copy preface-mode.el somewhere on disk and type:                                
`M-x: load-file -> path-to-preface-mode.el'.                                    

