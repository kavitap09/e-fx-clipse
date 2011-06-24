package at.bestsolution.efxclipse.tooling.css.web;

import static at.bestsolution.efxclipse.tooling.css.ui.CssDialectExtension.Util.createEnumProperties;
import static at.bestsolution.efxclipse.tooling.css.ui.CssDialectExtension.Util.createReflective;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import at.bestsolution.efxclipse.tooling.css.ui.CssDialectExtension.Property;
import at.bestsolution.efxclipse.tooling.css.ui.CssDialectExtension.Proposal;

public class Fonts {
	public static List<Property> init() {
		List<Property> PROPERTIES = new ArrayList<Property>();
		PROPERTIES.addAll(createReflective(FontFamilyProperty.class, "font-family"));
		PROPERTIES.addAll(createReflective(FontSizeProperty.class, "font-size"));
		
		PROPERTIES.addAll(
				createEnumProperties(
					Arrays.asList("normal","italic","oblique","inherit"), 
					"font-style")
			);
			PROPERTIES.addAll(
				createEnumProperties(
					Arrays.asList("normal","small-caps","inherit"), 
					"font-variant")
			);
			PROPERTIES.addAll(
				createEnumProperties(
					Arrays.asList("normal","bold","bolder","lighter","100","200","300","400","500","600","700","800","900","inherit"), 
					"font-weight")
			);
			
		PROPERTIES.addAll(createReflective(FontProperty.class, "font"));
			
		return PROPERTIES;
	}
	
	private static class FontFamilyProperty extends Property {
		private List<Proposal> proposals = new ArrayList<Proposal>();
		
		public FontFamilyProperty(String name) {
			super(name);
		}
		
		@Override
		public List<Proposal> getInitialValueProposals() {
			return proposals;
		}
	}
	
	private static class FontSizeProperty extends Property {
		private List<Proposal> proposals = new ArrayList<Proposal>();
		
		public FontSizeProperty(String name) {
			super(name);
		}
		
		@Override
		public List<Proposal> getInitialValueProposals() {
			return proposals;
		}
	}
	
	private static class FontProperty extends Property {
		private List<Proposal> proposals = new ArrayList<Proposal>();
		
		public FontProperty(String name) {
			super(name);
		}
		
		@Override
		public List<Proposal> getInitialValueProposals() {
			return proposals;
		}
	}
}
