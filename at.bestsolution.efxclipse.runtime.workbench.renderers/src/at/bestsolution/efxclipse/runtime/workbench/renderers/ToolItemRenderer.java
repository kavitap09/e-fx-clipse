package at.bestsolution.efxclipse.runtime.workbench.renderers;

import java.net.URL;

import javafx.scene.control.Button;
import javafx.scene.control.Tooltip;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

import javax.inject.Inject;

import org.eclipse.e4.core.services.contributions.IContributionFactory;
import org.eclipse.e4.ui.model.application.ui.MUIElement;
import org.eclipse.e4.ui.model.application.ui.menu.MDirectToolItem;
import org.eclipse.e4.ui.model.application.ui.menu.MHandledItem;
import org.eclipse.e4.ui.model.application.ui.menu.MHandledToolItem;
import org.eclipse.e4.ui.model.application.ui.menu.MToolItem;
import org.eclipse.emf.common.util.URI;

@SuppressWarnings("restriction")
public class ToolItemRenderer extends ItemRenderer {
	@Inject
	IContributionFactory contributionFactory;

	@Override
	public Object createWidget(MUIElement element, Object parent) {
		Button button = new Button();

		MToolItem item = (MToolItem) element;
		if (item.getIconURI() != null) {
			URL url = Util.convertToOSGiURL(URI.createURI(item.getIconURI()));
			Image img = new Image(url.toExternalForm());
			button.setGraphic(new ImageView(img));
		}
		if (item.getTooltip() != null) {
			button.setTooltip(new Tooltip(item.getLocalizedTooltip()));
		}

		return button;
	}

	@Override
	public void hookControllerLogic(MUIElement me) {
		if (me instanceof MDirectToolItem) {
			final MDirectToolItem item = (MDirectToolItem) me;
			item.setObject(contributionFactory.create(item.getContributionURI(), getContext(item)));

			Button button = (Button) item.getWidget();
			button.setOnAction(createEventHandler(item));
		} else if (me instanceof MHandledToolItem) {
			final MHandledItem item = (MHandledToolItem) me;

			Button button = (Button) item.getWidget();
			button.setOnAction(createParametrizedCommandEventHandler(item));
		}
	}
}