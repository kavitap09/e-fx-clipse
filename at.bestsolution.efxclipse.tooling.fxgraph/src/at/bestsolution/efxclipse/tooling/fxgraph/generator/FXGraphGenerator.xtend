/*
 * generated by Xtext
 */
package at.bestsolution.efxclipse.tooling.fxgraph.generator

import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.ComponentDefinition
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.ControllerHandledValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.CopyValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.Element
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.IncludeValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.ListValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.MapValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.Property
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.ReferenceValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.ScriptHandlerHandledValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.ScriptValueExpression
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.SimpleValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.StaticValueProperty
import java.util.List
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.jdt.core.IClasspathEntry
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtext.common.types.JvmTypeReference
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.xbase.compiler.ImportManager
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.LocationValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.ResourceValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.BindValueProperty
import at.bestsolution.efxclipse.tooling.fxgraph.fXGraph.Model

class FXGraphGenerator implements IGenerator {
	
	def calculateRelativePath(Resource resource) { 
		
			if( resource.URI.platformResource ) {
				var uri = resource.URI;
				var root = ResourcesPlugin::workspace.root;
				var project = root.getProject(uri.segment(1));
				var projectRelativePath = "";
				
//				var i = 2;
//				while( i < uri.segmentCount ) {
//					projectRelativePath = projectRelativePath + "/" + uri.segment(i);
//					i = i + 1;
//				}
//				
				var i = 0;
			
				for( seg : uri.segments ) {
					if( i >= 1 ) {
						projectRelativePath = projectRelativePath + "/" + uri.segment(i);
					}
					i = i + 1;
				}
			
				var file = project.getFile(projectRelativePath);
				var jproject = JavaCore::create(project);
				var prefix = null;
				for( packroot: jproject.rawClasspath ) {
					if( packroot.entryKind == IClasspathEntry::CPE_SOURCE ) {
						if( projectRelativePath.startsWith(packroot.path.toString) ) {
							projectRelativePath = projectRelativePath.substring(packroot.path.toString.length);
						}
					}
				}
				
//				System::err.println("The path: " + projectRelativePath);
				
				return projectRelativePath;		
			} else {
				return null;
			}
		
	}
	
	def doGeneratePreview(Resource resource, boolean skipController, boolean skipIncludes) {
		try {
			val projectRelativePath = calculateRelativePath(resource);
			if( projectRelativePath != null ) {
				return createContent(resource, projectRelativePath,skipController,skipIncludes).toString;
			}	
		} catch(Exception e) {
			
		}
		
		return null;
	}
		
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		try {
			val projectRelativePath = calculateRelativePath(resource);
		
			if( projectRelativePath != null ) {
				val relativeOutPath = projectRelativePath.replaceFirst(".fxgraph$",".fxml");
				fsa.generateFile(relativeOutPath, createContent(resource, projectRelativePath,false,false));
			}	
		} catch(Exception e) {
			
		}
		
	}
	
	
	def createContent(Resource resource, String projectRelativePath, boolean skipController, boolean skipIncludes) '''
		�val importManager = new ImportManager(true)�
		�val languageManager = new LanguageManager()�
		<?xml version="1.0" encoding="UTF-8"?>
		<!-- 
			Do not edit this file it is generated by e(fx)clipse from �projectRelativePath�
		-->
		
		�FOR rootElement : resource.contents.get(0).eContents.filter(typeof(ComponentDefinition))�
		�val body = componentDefinition(rootElement, importManager, languageManager, skipController, skipIncludes)�
		<?import java.lang.*?>
		�FOR i:importManager.imports�
			<?import �i�?>
		�ENDFOR�
		�FOR i:languageManager.languages�
			<?language �i�?>
		�ENDFOR�
		
		�body�
		�ENDFOR�
	'''
	
	def componentDefinition(ComponentDefinition definition, ImportManager importManager, LanguageManager languageManager, boolean skipController, boolean skipIncludes) '''
		�val element = definition.rootNode�
		<�element.type.shortName(importManager)� xmlns:fx="http://javafx.com/fxml"�fxElementAttributes(element,importManager,skipController)��IF definition.controller != null && ! skipController � fx:controller="�definition.controller.qualifiedName�"�ENDIF��IF hasAttributeProperties(element)��elementAttributes(element.properties,skipController)��ENDIF�>
			�IF definition.defines.size > 0�
			<fx:define>
				�FOR define : definition.defines�
				�elementContent(define.element,importManager,skipController,skipIncludes)�
				�ENDFOR�
			</fx:define>
			�ENDIF�
			�IF ! skipController�
			�FOR script : definition.scripts��languageManager.addLanguage(script.language)�
				�IF script.sourcecode != null�
					<fx:script>�script.sourcecode.substring(2,script.sourcecode.length-2)�
					</fx:script>
				�ELSE�
					<fx:script source="�script.source�"/>
				�ENDIF�
			�ENDFOR�
			�ENDIF�
		
			�IF hasNestedProperties(element)�
				�propContents(element.properties,importManager,false,skipController,skipIncludes)�
				�statPropContent(element.staticProperties,importManager,skipController,skipIncludes)�
			�ENDIF�
		
		</�element.type.shortName(importManager)�>
	'''
	
	def elementContent(Element element, ImportManager importManager, boolean skipController, boolean skipIncludes) '''
		<�element.type.shortName(importManager)��fxElementAttributes(element,importManager,skipController)��IF hasAttributeProperties(element)��elementAttributes(element.properties,skipController)��ENDIF��IF ! hasNestedProperties(element)�/�ENDIF�> 
		�IF hasNestedProperties(element)�
			�propContents(element.properties,importManager,false,skipController,skipIncludes)�
			�statPropContent(element.staticProperties,importManager,skipController,skipIncludes)�
			�FOR e : element.values�
			�elementContent(e,importManager,skipController,skipIncludes)�
			�ENDFOR�
		</�element.type.shortName(importManager)�>
		�ENDIF�
	'''
	
	def propContents(List<Property> properties, ImportManager importManager, boolean simpleAsElement, boolean skipController, boolean skipIncludes) '''
		�IF simpleAsElement�
			�FOR prop : properties�
				�propContent(prop,importManager,simpleAsElement,skipController,skipIncludes)�
			�ENDFOR�
		�ELSE�
			�FOR prop : properties.filter([Property p|subelementFilter(p)])�
				�propContent(prop,importManager,simpleAsElement,skipController,skipIncludes)�
			�ENDFOR�
		�ENDIF�
	'''
	
	def propContent(Property prop, ImportManager importManager, boolean simpleAsElement, boolean skipController, boolean skipIncludes) '''
		�IF prop.value instanceof SimpleValueProperty�
			�IF (prop.value as SimpleValueProperty).stringValue != null�
				<�prop.name�>�(prop.value as SimpleValueProperty).stringValue�</�prop.name�>
			�ELSEIF simpleAsElement�
				<�prop.name�>�(prop.value as SimpleValueProperty).simpleAttributeValue�</�prop.name�>
			�ENDIF�
		�ELSEIF prop.value instanceof ListValueProperty�
			<�prop.name�>
				�propListContent(prop.value as ListValueProperty,importManager, skipController, skipIncludes)�
			</�prop.name�>
		�ELSEIF prop.value instanceof MapValueProperty�
			<�prop.name�>
				�propContents((prop.value as MapValueProperty).properties,importManager,true,skipController,skipIncludes)�
			</�prop.name�>
		�ELSEIF prop.value instanceof Element�
			<�prop.name�>
				�elementContent(prop.value as Element,importManager,skipController,skipIncludes)�
			</�prop.name�>
		�ELSEIF prop.value instanceof ReferenceValueProperty�
			�IF !skipIncludes�
				<�prop.name�>
					<fx:reference source="�(prop.value as ReferenceValueProperty).reference.name�" />
				</�prop.name�>
			�ENDIF�
		�ELSEIF prop.value instanceof IncludeValueProperty�
			�IF !skipIncludes�
				<�prop.name�>
					<fx:include source="/�(prop.value as IncludeValueProperty).source.fullyQualifiedName.replaceAll("\\.","/")�.fxml" />
				</�prop.name�>
			�ENDIF�
		�ELSEIF prop.value instanceof CopyValueProperty�
			<�prop.name�>
				<fx:copy source="�(prop.value as CopyValueProperty).reference.name�" />
			</�prop.name�>
		�ENDIF�
	'''
	
	def statPropContent(List<StaticValueProperty> properties, ImportManager importManager, boolean skipController, boolean skipIncludes) '''
		�FOR prop : properties�
		�IF prop.value instanceof SimpleValueProperty�
			�IF (prop.value as SimpleValueProperty).stringValue != null�
				<�prop.type.shortName(importManager)�.�prop.name�>�(prop.value as SimpleValueProperty).stringValue�</�prop.type.shortName(importManager)�.�prop.name�>
			�ELSE�
				<�prop.type.shortName(importManager)�.�prop.name�>�simpleAttributeValue(prop.value as SimpleValueProperty)�</�prop.type.shortName(importManager)�.�prop.name�>
			�ENDIF�
		�ELSEIF prop.value instanceof ListValueProperty�
			<�prop.type.shortName(importManager)�.�prop.name�>
				�propListContent(prop.value as ListValueProperty,importManager, skipController, skipIncludes)�
			</�prop.type.shortName(importManager)�.�prop.name�>
		�ELSEIF prop.value instanceof MapValueProperty�
			<�prop.type.shortName(importManager)�.�prop.name�>
				�propContents((prop.value as MapValueProperty).properties,importManager,true, skipController, skipIncludes)�
			</�prop.type.shortName(importManager)�.�prop.name�>
		�ELSEIF prop.value instanceof Element�
			<�prop.type.shortName(importManager)�.�prop.name�>
				�elementContent(prop.value as Element,importManager, skipController, skipIncludes)�
			</�prop.type.shortName(importManager)�.�prop.name�>
		�ELSEIF prop.value instanceof ReferenceValueProperty�
			<�prop.type.shortName(importManager)�.�prop.name�>
				<fx:reference source="�(prop.value as ReferenceValueProperty).reference.name�" />
			</�prop.type.shortName(importManager)�.�prop.name�>
		�ELSEIF prop.value instanceof IncludeValueProperty�
			�IF ! skipIncludes�
				<�prop.type.shortName(importManager)�.�prop.name�>
					<fx:include source="/�(prop.value as IncludeValueProperty).source.fullyQualifiedName.replaceAll("\\.","/")�.fxml" />
				</�prop.type.shortName(importManager)�.�prop.name�>
			�ENDIF�
		�ELSEIF prop.value instanceof CopyValueProperty�
			<�prop.type.shortName(importManager)�.�prop.name�>
				<fx:copy source="�(prop.value as CopyValueProperty).reference.name�" />
			</�prop.type.shortName(importManager)�.�prop.name�>
		�ENDIF�
		�ENDFOR�
	'''
	
	def propListContent(ListValueProperty listProp, ImportManager importManager, boolean skipController, boolean skipIncludes) '''
		�FOR e : listProp.value�
			�IF e instanceof Element�
				�elementContent(e as Element,importManager,skipController, skipIncludes)�
			�ELSEIF e instanceof ReferenceValueProperty�
				<fx:reference source="�(e as ReferenceValueProperty).reference.name�" />
			�ELSEIF e instanceof IncludeValueProperty�
				�IF !skipIncludes�
					<fx:include source="/�(e as IncludeValueProperty).source.fullyQualifiedName.replaceAll("\\.","/")�.fxml" />
				�ENDIF�
			�ENDIF�
		�ENDFOR�
	'''

    def fullyQualifiedName(ComponentDefinition cp) {
    	val m = cp.eResource.contents.get(0) as Model;
    	
    	if( m.getPackage != null) {
    		return m.getPackage.name + "." + cp.name;
    	} else {
    		return cp.name;
    	}
    }

	def fxElementAttributes(Element element, ImportManager importManager, boolean skipController) {
		var builder = new StringBuilder();
		
		if(element.name != null) {
			builder.append(" fx:id=\""+element.name+"\"");
		}
		
		if( element.value != null ) {
			builder.append(" fx:value=\""+ simpleAttributeValue(element.value) + "\"");
		} else if( element.factory != null ) {
			builder.append(" fx:factory=\""+ element.factory + "\"");
		}
		
		return builder.toString;
	}
	
	def elementAttributes(List<Property> properties, boolean skipController) {
		var builder = new StringBuilder();
		
		for( p : properties.filter([Property p|elementAttributeFilter(p)]) ) {
			if( p.value instanceof SimpleValueProperty ) {
				builder.append(" " + p.name + "=\""+simpleAttributeValue(p.value as SimpleValueProperty)+"\"");
			} else if( p.value instanceof ReferenceValueProperty ) {
				builder.append(" " + p.name + "=\"$"+(p.value as ReferenceValueProperty).reference.name+"\"");
			} else if( p.value instanceof ControllerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.name + "=\"#"+(p.value as ControllerHandledValueProperty).methodname +"\"");
				}
			} else if( p.value instanceof ScriptHandlerHandledValueProperty ) {
				if( ! skipController ) {
					builder.append(" " + p.name + "=\""+(p.value as ScriptHandlerHandledValueProperty).functionname +"\"");
				}
			} else if( p.value instanceof ScriptValueExpression ) {
				if( ! skipController ) {
					builder.append(" " + p.name + "=\""+(p.value as ScriptValueExpression).sourcecode.substring(2,(p.value as ScriptValueExpression).sourcecode.length-2).trim() +";\"");	
				}
			} else if( p.value instanceof LocationValueProperty ) {
				builder.append(" " + p.name + "=\"@"+(p.value as LocationValueProperty).value+"\"");
			} else if( p.value instanceof ResourceValueProperty ) {
				builder.append(" " + p.name + "=\"%"+(p.value as ResourceValueProperty).value.value+"\"");
			} else if( p.value instanceof BindValueProperty ) {
				builder.append(" " + p.name + "=\"${"+(p.value as BindValueProperty).elementReference.name+"."+(p.value as BindValueProperty).attribute+"}\"");
			}
		}
		
		return builder;
	}
	
	def subelementFilter(Property property) {
		return ! elementAttributeFilter(property);
	}

	def elementAttributeFilter(Property property) {
		if( property.value instanceof SimpleValueProperty ) {
			if( (property.value as SimpleValueProperty).stringValue == null ) {
				return true;
			}
		} else if( property.value instanceof ReferenceValueProperty ) {
			return true;
		} else if( property.value instanceof ControllerHandledValueProperty ) {
			return true;
		} else if( property.value instanceof ScriptHandlerHandledValueProperty ) {
			return true;
		} else if( property.value instanceof ScriptValueExpression ) {
			return true;
		} else if( property.value instanceof LocationValueProperty ) {
			return true;
		} else if( property.value instanceof ResourceValueProperty ) {
			return true;
		} else if( property.value instanceof BindValueProperty ) {
			return true;
		}
		return false;
	}

	def simpleAttributeValue(SimpleValueProperty value) {
		if( value.stringValue != null ) {
			return value.stringValue;
		} else if( value.booleanValue != null ) {
			return value.booleanValue;
		} else if( (value.realValue as int) != 0 ) {
			if( value.negative ) {
				return "-" + value.realValue;
			} else {
				return value.realValue;
			}
		} else {
			if( value.negative ) {
				return "-" + value.intValue;
			} else {
				return value.intValue;
			}
		}
	}
	
	def hasAttributeProperties(Element element) {
		return element.properties.size > 0 && ! element.properties.filter([Property p|elementAttributeFilter(p)]).nullOrEmpty;
	}
	
	def hasNestedProperties(Element element) {
		if( element.values.size > 0 ) {
			return true;
		}
		
		if( element.staticProperties.size > 0) {
			return true;
		}
		
		if( element.properties.size > 0 ) {
			return ! element.properties.filter([Property p|subelementFilter(p)]).nullOrEmpty;
		}
		
		return false;
	}
	
	def shortName(JvmTypeReference r, ImportManager importManager) {
		val builder = new StringBuilder()
		importManager.appendType(r.type, builder)
		builder.toString
	}
}
