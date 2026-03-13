// wget https://repo1.maven.org/maven2/org/alloytools/org.alloytools.alloy.dist/6.2.0/org.alloytools.alloy.dist-6.2.0.jar into sister directory libs

// jenv local 17.0.16
// jenv shell 17.0.16
// run this with 
// javac -cp ../scoring/org.alloytools.alloy.dist-6.2.0.jar InstanceChecker.java
// java -cp .:../scoring/org.alloytools.alloy.dist-6.2.0.jar InstanceChecker modelfileName xmlFileName 

// expect the XML to contain a command of the form `Run run$ for 16`, where 16 is the scope
// so this script gets the scope from the command in the XML

import java.io.File;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.NodeList;
import org.w3c.dom.Element;

import java.nio.file.Path;
import java.nio.file.Files;
import java.nio.charset.StandardCharsets;


import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.alloy4.XMLNode;

import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.ast.Sig.PrimSig;
import edu.mit.csail.sdg.ast.Sig.Field;

import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;

import edu.mit.csail.sdg.translator.A4Options;
import edu.mit.csail.sdg.translator.A4Solution;
import edu.mit.csail.sdg.translator.A4SolutionReader;
import edu.mit.csail.sdg.translator.A4Tuple;
import edu.mit.csail.sdg.translator.A4TupleSet;
import edu.mit.csail.sdg.translator.TranslateAlloyToKodkod;

import kodkod.ast.Relation;


public class InstanceChecker {

    private static boolean isBuiltIn(Element sig) {
        return sig.hasAttribute("builtin");
    }

    private static String alloyName(String name) {
        if (name.contains("$")) {
            return name.replace("$","ʃ") ;
        } else if (name.startsWith("this/")) {
            return name.replace("this/","");
        } else 
            return name;
    }

    private static int getFieldArity(Element field) {

        NodeList typesList = field.getElementsByTagName("types");
        if (typesList.getLength() == 0) return 0;
        Element types = (Element) typesList.item(0);
        NodeList typeNodes = types.getElementsByTagName("type");
        return typeNodes.getLength();
    }

    public static void main(String[] args) throws Exception {

        if (args.length != 2) {
            System.err.println("FAIL: Args required: modelfileName xmlFileNamem");
            System.exit(1);
        }

        // check args are fine
        String modelFileName = args[0];
        String xmlFileName = args[1];

        Path modelPath = Path.of(modelFileName).toAbsolutePath();  
        String modelFullFileName = modelPath.toString();
        if (!Files.exists(modelPath)) {
            System.out.println("File does not exist: " + modelFullFileName);
            System.exit(1);
        }

        Path xmlPath = Path.of(xmlFileName).toAbsolutePath();  
        String xmlFullFileName = xmlPath.toString();
        if (!Files.exists(xmlPath)) {
            System.out.println("File does not exist: " + xmlFullFileName);
            System.exit(1);
        }

        // read the contents of the input .als model
        String modelString = "";
        try {
            modelString = Files.readString(modelPath, StandardCharsets.UTF_8);
        } catch (Exception e) {
            System.out.println("FAIL: Reading "+modelFullFileName +" failed with\n" + e.getMessage());
            System.exit(1);
        }

        // create the CompModel of the .als file
        A4Reporter rep = new A4Reporter();
        CompModule modelWorld = null;
        try {
            modelWorld = CompUtil.parseEverything_fromString(rep, modelString);
        } catch (Exception e) {
            System.out.println("FAIL: Alloy jar failed to parse model with message\n" + e.getMessage());
            System.exit(1);
        }
    
        // get the field/sig names used in the model
        // these names include seq/Int, and other builtins
        // as well as this/E, etc.
        Set<String> modelNames = new HashSet<String>();
        for (Sig s : modelWorld.getAllReachableSigs()) {
            if (!s.builtin)
                modelNames.add(s.label);
            for (Sig.Field f : s.getFields()) {
                modelNames.add(f.label);
            }   
        }
        
        // read the XML file
        // let's not rely on Alloy at all
        // and do the XML parsing ourselves
        Document doc = null;
        Set<String> xmlNames = new HashSet<String>();
        NodeList sigs = null;
        NodeList fields = null;
        String univID = null;
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            doc = builder.parse(new File(xmlFullFileName));
            sigs = doc.getElementsByTagName("sig");
            for (int i = 0; i < sigs.getLength(); i++) {
                Element sig = (Element) sigs.item(i);
                if (sig.getAttribute("label").equals("univ")) 
                    // top-level sigs have univ as parent in XML
                    // so we need to get the id of univ
                    univID = sig.getAttribute("ID");
                String label = sig.getAttribute("label");
                xmlNames.add(label);
            }
            fields = doc.getElementsByTagName("field");
            for (int i = 0; i < fields.getLength(); i++) {
                Element field = (Element) fields.item(i);
                String label = field.getAttribute("label");
                xmlNames.add(label);
            }
        } catch (Exception e) {
            System.out.println("FAIL: Reading "+xmlFullFileName +" failed with\n" + e.getMessage());
            System.exit(1);
        }


        // the names of the model can contain things like `none`
        // check the modelNames subseteq of xmlNames
        // because the problem of names used in the XML that are not used in the model
        // will be caught in the Alloy solving below
        // but if the model contains names not used in the XML, the solver will 
        // provide values for them
        if (!xmlNames.containsAll(modelNames)) {
            System.out.println("FAIL: Model has sigs/fields not in XML:");
            System.out.println(modelNames.removeAll(xmlNames));   
            System.exit(1);
        }

        // if the scopes are incompatible between the model and the xml
        // that will come out in the facts because the xml facts
        // set the scopes to a specific size

        // create a string that is one sigs and facts that represent the instance in Alloy
        StringBuilder newSigs = new StringBuilder();
        StringBuilder newFacts = new StringBuilder();
        
        NodeList atoms;
        List<String> atomList;
        Element sig;
        String sigLabel;
        Element atom;
        String atomLabel;
        for (int i=0; i < sigs.getLength(); i++) {
            sig = (Element) sigs.item(i);
            sigLabel = sig.getAttribute("label");
            if (!isBuiltIn(sig)) {
                atoms = sig.getElementsByTagName("atom");
                atomList = new ArrayList<String>();
                for (int j = 0; j < atoms.getLength(); j++) {
                    atom = (Element) atoms.item(j);
                    atomLabel = atom.getAttribute("label");
                    if (sig.getAttribute("parentID").equals(univID)); 
                        // one sig atom_name extends sig name {}
                        newSigs.append("\none sig "+ alloyName(atomLabel) + " extends "+ alloyName(sigLabel) + " {}");
                    atomList.add(alloyName(atomLabel));
                }           
                // sig_name = a$1 + a$2 + ...
                newFacts.append("\n"+alloyName(sigLabel) + " = ");
                newFacts.append(String.join("\n   + ", atomList) );
            }
        }

        // add facts for the fields
        Element field;
        String fieldLabel;
        Integer arity;
        NodeList tuples;
        List<String> arrows;
        List<String> arrow;
        Element tuple;
        for (int i = 0; i < fields.getLength(); i++) {
            field = (Element) fields.item(i);
            fieldLabel = field.getAttribute("label");
            arity = getFieldArity(field);
            tuples = field.getElementsByTagName("tuple");
            arrows = new ArrayList<String>();
            if (tuples.getLength() == 0) {
                arrows.add(String.join(" -> ", java.util.Collections.nCopies(arity, "none")));
            } else {
                arrows = new ArrayList<String>();
                for (int k=0; k < tuples.getLength(); k++) {
                    tuple = (Element) tuples.item(k);
                    atoms = tuple.getElementsByTagName("atom");     
                    arrow = new ArrayList<String>();
                    for (int j=0; j < atoms.getLength(); j++) {
                        atom = (Element) atoms.item(j);
                        atomLabel = atom.getAttribute("label");
                        arrow.add(alloyName(atomLabel));
                    }
                    arrows.add(String.join(" -> ", arrow));
                }
                // f_name = a$1 -> b$2 + a$2 -> b$3 + ...
                newFacts.append("\n"+alloyName(fieldLabel) +" = ");
                newFacts.append(String.join("\n   + ", arrows));
            }        
        }

        // create a string that is the model plus the sigs and facts representing the instance
        StringBuilder checkerModel =  new StringBuilder(modelString); 
        checkerModel.append(newSigs);
        checkerModel.append("\nfact {"+newFacts+"\n}\n");

        // tack on the end of the model, the cmd that this XML is supposed to
        // satisfy and remember the cmd's number in satCmdNum
        // the cmd will tell us the scope
        NodeList inst = doc.getElementsByTagName("instance");
        if (inst.getLength() > 1) {
            System.out.println("FAIL: More than one instance in XML\n");
            System.exit(1);
        }
        Element x = (Element) inst.item(0);
        // this is hacky but works for our purposes
        // and gets the scope from the XML file
        String cmd = x.getAttribute("command");
        if (!cmd.startsWith("Run run$")) {
            System.out.println("FAIL: Instance should be for a run {} cmd\n");
            System.exit(1);
        }
        cmd = cmd.replace("Run run$1", "run {}");
        checkerModel.append("\n\n"+cmd);     
        Integer modelNumCmds = modelWorld.getAllCommands().size();  
        Integer satCmdNum = modelNumCmds;   // cmds are zero indexed

        A4Solution sol = null;
        try {
            // check if checkerModel is Sat
            // parsing or solve will fail if xml has names that model does not
            CompModule checkerModelWorld = CompUtil.parseEverything_fromString(rep, checkerModel.toString());
            // this is the only place we do solving
            // hopefully it is quick because the instance is specific
            A4Options opt = new A4Options();
            sol = TranslateAlloyToKodkod.execute_command(rep, checkerModelWorld.getAllReachableSigs(), checkerModelWorld.getAllCommands().get(satCmdNum), opt);  
        } catch (Exception e) {
            System.out.println("FAIL: Solving checker model failed with\n" + e.getMessage());
            System.exit(1);
        }
        
        if (!sol.satisfiable()) {
            System.out.println("FAIL: checkerModel unsat");
            System.exit(1);
        } else {
            System.out.println("PASS: xml is instance of model");
            System.exit(0);
        }
    }

}
    
    



